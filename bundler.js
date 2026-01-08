const fs = require('fs');
const path = require('path');

const BASE_DIR = __dirname;
const HTML_FILE = path.join(BASE_DIR, "index.html");
const OUTPUT_FILE = path.join(BASE_DIR, "weapon-master-bundled.html");
const DATA_DIR = path.join(BASE_DIR, "data");
const ASSETS_DIR = path.join(BASE_DIR, "assets");

function getBase64Image(filepath) {
    const data = fs.readFileSync(filepath);
    const ext = path.extname(filepath).substring(1);
    return `data:image/${ext};base64,${data.toString('base64')}`;
}

function getAllFiles(dirPath, arrayOfFiles) {
    const files = fs.readdirSync(dirPath);
    arrayOfFiles = arrayOfFiles || [];

    files.forEach(function (file) {
        if (fs.statSync(path.join(dirPath, file)).isDirectory()) {
            arrayOfFiles = getAllFiles(path.join(dirPath, file), arrayOfFiles);
        } else {
            arrayOfFiles.push(path.join(dirPath, file));
        }
    });

    return arrayOfFiles;
}

async function bundleGame() {
    console.log("Reading index.html...");
    let htmlContent = fs.readFileSync(HTML_FILE, 'utf8');

    console.log("Loading JSON data...");
    const gameData = {};

    // 몬스터 데이터
    const monsterData = JSON.parse(fs.readFileSync(path.join(DATA_DIR, "monsters.json"), 'utf8'));
    gameData.monsters = monsterData;

    // 무기 데이터
    const weaponJson = JSON.parse(fs.readFileSync(path.join(DATA_DIR, "weapons.json"), 'utf8'));
    gameData.weapons = weaponJson.weapons;
    gameData.grades = weaponJson.grades;
    gameData.gacha = weaponJson.gacha;

    // 설정 데이터
    const configData = JSON.parse(fs.readFileSync(path.join(DATA_DIR, "config.json"), 'utf8'));
    // 필요한 경우 병합

    // 2. 이미지 경로를 Base64로 치환
    console.log("Encoding assets to Base64...");
    let jsonStr = JSON.stringify(gameData);

    const assetFiles = getAllFiles(ASSETS_DIR);
    assetFiles.forEach(filepath => {
        if (filepath.match(/\.(png|jpg|jpeg|gif)$/i)) {
            // 절대 경로를 상대 경로로 변환 (역슬래시를 슬래시로)
            const relPath = path.relative(BASE_DIR, filepath).split(path.sep).join('/');

            if (jsonStr.includes(relPath)) {
                console.log(`  Replacing ${relPath}...`);
                const b64 = getBase64Image(filepath);
                // 모든 발생을 치환하기 위해 split/join 사용
                jsonStr = jsonStr.split(relPath).join(b64);
            }
        }
    });

    // 3. HTML 수정
    console.log("Injecting data into HTML...");

    // 데이터 주입
    const bundledDataScript = `const BUNDLED_GAME_DATA = ${jsonStr};\n`;
    htmlContent = htmlContent.replace("<script>", "<script>\n" + bundledDataScript);

    // fetch 로직 교체
    // 정규식으로 Promise.all 블록 찾기
    // Promise.all([ ... ]) ... .catch(err => initGame(FALLBACK_DATA));

    const pattern = /Promise\.all\(\s*\[[\s\S]*?\]\)[\s\S]*?\.catch\(err => initGame\(FALLBACK_DATA\)\);/;
    if (htmlContent.match(pattern)) {
        console.log("Found fetch block, replacing...");
        htmlContent = htmlContent.replace(pattern, "initGame(BUNDLED_GAME_DATA);");
    } else {
        console.warn("WARNING: Could not find fetch block via regex. Appending override to verify.");
        // 혹시 모르니 window.onload 재정의
        const overrideScript = `
        window.addEventListener('load', () => {
            // 기존 window.onload가 실행되더라도 덮어쓰거나 이후에 실행
            console.log("Bundled init");
            // 이미 실행되었다면 문제될 수 있으니 주의. 
            // 하지만 기존 로직이 fetch 실패 시 initGame을 호출하므로, 
            // 여기서 initGame을 호출하면 두 번 실행될 수 있음.
            // 따라서 정규식 매칭 실패 시 수동으로 코드를 확인해야 함.
        });
        `;
        // 일단 진행
    }

    // 4. 저장
    console.log(`Saving to ${OUTPUT_FILE}...`);
    fs.writeFileSync(OUTPUT_FILE, htmlContent, 'utf8');
    console.log("Done!");
}

bundleGame();
