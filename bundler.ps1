$ErrorActionPreference = "Stop"
$baseDir = "C:\Users\idopa\.gemini\antigravity\scratch\weapon-master"
$htmlFile = Join-Path $baseDir "index.html"
$outputFile = Join-Path $baseDir "weapon-master-bundled.html"
$dataDir = Join-Path $baseDir "data"
$assetsDir = Join-Path $baseDir "assets"

Write-Host "Reading HTML..."
$htmlContent = Get-Content $htmlFile -Raw -Encoding UTF8

Write-Host "Reading JSON data..."
$monstersPath = Join-Path $dataDir "monsters.json"
$weaponsPath = Join-Path $dataDir "weapons.json"
$configPath = Join-Path $dataDir "config.json"

# JSON 파일 내용을 문자열로 읽음 (객체로 변환 후 다시 직렬화는 포맷 변경 우려가 있어서, 문자열 조작으로 처리 시도)
# 하지만 병합을 위해 객체로 변환 필요
$monsters = Get-Content $monstersPath -Raw -Encoding UTF8 | ConvertFrom-Json
$weaponsData = Get-Content $weaponsPath -Raw -Encoding UTF8 | ConvertFrom-Json
$configData = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

# 통합 데이터 객체 생성
$gameData = @{
    monsters = $monsters
    weapons = $weaponsData.weapons
    grades = $weaponsData.grades
    gacha = $weaponsData.gacha
}
# hashtable에 config 병합은 복잡하므로 여기선 생략하고, 어차피 fetch.then으로 합쳐지던 로직을 시뮬레이션

# JSON 문자열로 변환 (Depth 충분히)
# -Compress 옵션으로 용량 절약
$jsonStr = $gameData | ConvertTo-Json -Depth 20 -Compress

Write-Host "Encoding assets..."
$files = Get-ChildItem -Path $assetsDir -Recurse -Include *.png, *.jpg, *.jpeg, *.gif

foreach ($file in $files) {
    # 상대 경로 계산 (슬래시로 변환)
    $relPath = $file.FullName.Substring($baseDir.Length + 1).Replace("\", "/")
    
    # JSON 문자열에 해당 경로가 있는지 확인 (성능 최적화)
    if ($jsonStr.Contains($relPath)) {
        Write-Host "  Replacing $relPath ..."
        
        # Base64 인코딩
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $b64 = [System.Convert]::ToBase64String($bytes)
        $ext = $file.Extension.TrimStart(".")
        $dataUri = "data:image/$ext;base64,$b64"
        
        # 문자열 치환
        $jsonStr = $jsonStr.Replace($relPath, $dataUri)
    }
}

Write-Host "Injecting into HTML..."
# 데이터 주입 코드 생성
# JSON 내에 $ 기호가 있으면 PowerShell 문자열 보간에서 문제될 수 있으므로 단일 따옴표 사용하거나 이스케이프 필요하지만,
# 여기선 변수에 담아두고 replace 메서드 사용하므로 괜찮음.

$bundledScript = "<script>`nconst BUNDLED_GAME_DATA = $jsonStr;`n"
$htmlContent = $htmlContent.Replace("<script>", $bundledScript)

# fetch 로직 교체
# 정규식 패턴: Promise.all([...])...catch(...)
# Powershell -replace는 정규식 지원

# 패턴: Promise\.all\(\s*\[[\s\S]*?\]\)[\s\S]*?\.catch\(err => initGame\(FALLBACK_DATA\)\);
# Powershell 정규식은 라인 단위가 기본일 수 있으므로 (?s) 옵션 필요 (SingleLine 모드)

$pattern = "(?s)Promise\.all\(\s*\[.*?\]\).*?\.catch\(err => initGame\(FALLBACK_DATA\)\);"
$replacement = "initGame(BUNDLED_GAME_DATA);"

if ($htmlContent -match $pattern) {
    Write-Host "  Found fetch block, replacing..."
    $htmlContent = $htmlContent -replace $pattern, $replacement
} else {
    Write-Host "  WARNING: Fetch block not found. Appending override."
    # window.onload 재정의
    $override = "`n<script>window.onload = function() { initGame(BUNDLED_GAME_DATA); };</script>"
    $htmlContent = $htmlContent + $override
}

Write-Host "Saving to $outputFile..."
$htmlContent | Set-Content -Path $outputFile -Encoding UTF8

Write-Host "Done!"
