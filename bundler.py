import os
import json
import base64
import re

# 설정
BASE_DIR = r"C:\Users\idopa\.gemini\antigravity\scratch\weapon-master"
HTML_FILE = os.path.join(BASE_DIR, "index.html")
OUTPUT_FILE = os.path.join(BASE_DIR, "weapon-master-bundled.html")
DATA_DIR = os.path.join(BASE_DIR, "data")
ASSETS_DIR = os.path.join(BASE_DIR, "assets")

def get_base64_image(filepath):
    """이미지 파일을 Base64 문자열로 변환"""
    with open(filepath, "rb") as f:
        data = f.read()
        ext = os.path.splitext(filepath)[1][1:] # png, jpg 등
        return f"data:image/{ext};base64,{base64.b64encode(data).decode('utf-8')}"

def bundle_game():
    print("Reading index.html...")
    with open(HTML_FILE, "r", encoding="utf-8") as f:
        html_content = f.read()

    # 1. JSON 데이터 로드 및 병합
    print("Loading JSON data...")
    game_data = {}
    
    # 몬스터 데이터
    with open(os.path.join(DATA_DIR, "monsters.json"), "r", encoding="utf-8") as f:
        game_data["monsters"] = json.load(f)
        
    # 무기 데이터
    with open(os.path.join(DATA_DIR, "weapons.json"), "r", encoding="utf-8") as f:
        weapon_json = json.load(f)
        game_data["weapons"] = weapon_json["weapons"]
        game_data["grades"] = weapon_json["grades"]
        game_data["gacha"] = weapon_json["gacha"]
        
    # 설정 데이터
    with open(os.path.join(DATA_DIR, "config.json"), "r", encoding="utf-8") as f:
        config_json = json.load(f)
        # config는 FALLBACK_DATA 구조에 직접 포함되지 않을 수 있으나, 필요한 경우 병합
        pass 

    # 2. 이미지 경로를 Base64로 치환 (데이터 내에서)
    print("Encoding assets to Base64...")
    
    # JSON 직렬화 후 문자열 치환 수행
    json_str = json.dumps(game_data, ensure_ascii=False)
    
    # assets 폴더 내의 파일들을 찾아 치환
    for root, dirs, files in os.walk(ASSETS_DIR):
        for file in files:
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, BASE_DIR).replace("\\", "/")
                
                # 원본 경로: assets/monsters/slime.png
                if rel_path in json_str:
                    print(f"  Replacing {rel_path}...")
                    b64_str = get_base64_image(abs_path)
                    json_str = json_str.replace(rel_path, b64_str)

    # 3. HTML 수정
    print("Injecting data into HTML...")
    
    # FALLBACK_DATA 교체
    # 패턴: const FALLBACK_DATA = { ... };
    # 주의: 중괄호 매칭이 어려우므로 단순히 변수 선언부를 찾아서 교체
    # 기존 코드: const FALLBACK_DATA = { ... };
    # 변경 코드: const FALLBACK_DATA = <JSON_STR>;
    
    # 정규식으로 FALLBACK_DATA 객체 리터럴을 찾기보다, 
    # const FALLBACK_DATA = 까지 찾고 그 뒤의 객체를 통째로 바꾸는 것은 위험할 수 있음.
    # 대신, initGame 호출 부분을 수정하여 번들된 데이터를 사용하게 함.
    
    # 3-1. 번들 데이터 변수 주입 (script 태그 시작 직후)
    bundled_data_script = f"const BUNDLED_GAME_DATA = {json_str};\n"
    html_content = html_content.replace("<script>", "<script>\n" + bundled_data_script)
    
    # 3-2. fetch 로직 무력화 및 번들 데이터 사용
    # window.onload 부분을 찾아 수정
    # 기존: Promise.all([fetch...]).then(...).catch(...)
    # 변경: initGame(BUNDLED_GAME_DATA);
    
    # 정규식으로 window.onload 블록 전체를 교체하는 것은 복잡하므로,
    # Promise.all 부분을 주석 처리하고 initGame 호출로 변경
    
    # 찾을 문자열 (공백 유동성 고려)
    start_pattern = r"Promise\.all\(\s*\["
    end_pattern = r"\.catch\(err => initGame\(FALLBACK_DATA\)\);"
    
    # 전체 블록을 찾기 어려우니, initGame 정의 앞에 코드를 삽입하여 
    # window.onload를 덮어쓰거나, 기존 로직을 수정.
    
    # 가장 안전한 방법: HTML 내의 fetch 관련 코드를 직접 문자열 replace로 수정
    target_code = """
        window.onload = () => {
            Promise.all([
                fetch('data/weapons.json').then(r => r.json()),
                fetch('data/monsters.json').then(r => r.json()),
                fetch('data/config.json').then(r => r.json())
            ])
            .then(([wData, mData, cData]) => {
                const data = {
                    weapons: wData.weapons,
                    grades: wData.grades,
                    gacha: wData.gacha,
                    monsters: mData,
                    ...cData
                };
                initGame(data);
            })
            .catch(err => initGame(FALLBACK_DATA));
        };
    """
    
    # 공백/줄바꿈이 다를 수 있으므로 핵심 부분만 찾아 교체 시도
    # 차라리 window.onload 값을 재할당하는 코드를 스크립트 마지막에 추가하는게 나을 수도 있음.
    # 하지만 기존 window.onload가 실행되면 에러가 날 수 있음 (fetch 실패 등).
    # 따라서 기존 window.onload를 찾아서 무력화해야 함.
    
    if "window.onload" in html_content:
        # 간단하게 fetch('data/weapons.json') 문자열을 포함하는 블록을 찾아서 수정
        # 여기서는 단순히 BUNDLED_GAME_DATA를 사용하도록 로직을 강제 변경
        
        new_onload = """
        window.onload = () => {
            console.log("Starting bundled game...");
            initGame(BUNDLED_GAME_DATA);
        };
        """
        
        # 기존 window.onload 부분을 정규식으로 찾아서 교체 시도
        # (패턴이 너무 길면 실패할 수 있음)
        
        # 대안: 기존의 Promise.all(...) 블록을 찾아서 교체
        pattern = r"Promise\.all\(\[[\s\S]*?\]\)[\s\S]*?\.catch\(err => initGame\(FALLBACK_DATA\)\);"
        
        match = re.search(pattern, html_content)
        if match:
            print("Found fetch block, replacing...")
            html_content = html_content.replace(match.group(0), "initGame(BUNDLED_GAME_DATA);")
        else:
            print("WARNING: Could not find fetch block via regex. Appending override.")
            html_content = html_content.replace("</script>", new_onload + "\n</script>")

    # 4. 저장
    print(f"Saving to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(html_content)
    
    print("Done!")

if __name__ == "__main__":
    bundle_game()
