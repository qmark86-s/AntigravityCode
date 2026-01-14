$ErrorActionPreference = "Stop"
$baseDir = "C:\Users\idopa\.gemini\antigravity\scratch\weapon-master"
$htmlFile = Join-Path $baseDir "index.html"
$outputFile = Join-Path $baseDir "weapon-master-bundled.html"

Write-Host "Reading HTML from $htmlFile..."
$htmlContent = Get-Content $htmlFile -Raw -Encoding UTF8

# 1. Inline Scripts
Write-Host "Inlining scripts..."
$scriptRegex = '<script src="js/(.+?)"></script>'
$scriptMatches = [regex]::Matches($htmlContent, $scriptRegex)

foreach ($match in $scriptMatches) {
    $fileName = $match.Groups[1].Value
    # Fix for nested Join-Path in one line or separate
    $jsDir = Join-Path $baseDir "js"
    $filePath = Join-Path $jsDir $fileName
    
    if (Test-Path $filePath) {
        Write-Host "  Inlining $fileName..."
        $scriptContent = Get-Content $filePath -Raw -Encoding UTF8
        $htmlContent = $htmlContent.Replace($match.Value, "<script>`n$scriptContent`n</script>")
    }
    else {
        Write-Warning "  Script file not found: $fileName"
    }
}

# 2. Prepare Data
Write-Host "Preparing Data..."
$dataDir = Join-Path $baseDir "data"
$dataFiles = @{
    "data/monsters.json" = Join-Path $dataDir "monsters.json"
    "data/weapons.json"  = Join-Path $dataDir "weapons.json"
    "data/config.json"   = Join-Path $dataDir "config.json"
}

$bundledData = @{}

foreach ($key in $dataFiles.Keys) {
    $path = $dataFiles[$key]
    if (Test-Path $path) {
        Write-Host "  Loading $key..."
        $jsonContent = Get-Content $path -Raw -Encoding UTF8
        $bundledData[$key] = $jsonContent
    }
}

# 3. Base64 Encode Assets
Write-Host "Encoding Assets..."
$assetsDir = Join-Path $baseDir "assets"
$assetFiles = Get-ChildItem -Path $assetsDir -Recurse -Include *.png, *.jpg, *.jpeg, *.gif, *.glb

$finalJsonObj = @{}
foreach ($key in $bundledData.Keys) {
    try {
        $finalJsonObj[$key] = $bundledData[$key] | ConvertFrom-Json
        # Data Validation
        if ($key -eq "data/monsters.json" -and $null -eq $finalJsonObj[$key].monsters) {
            Write-Warning "  Warning: monsters.json missing 'monsters' array property!"
        }
    }
    catch {
        Write-Warning "  Failed to parse JSON for $key"
    }
}

$jsonStr = $finalJsonObj | ConvertTo-Json -Depth 20 -Compress

foreach ($file in $assetFiles) {
    $relPath = $file.FullName.Substring($baseDir.Length + 1).Replace("\", "/")
    
    if ($jsonStr.Contains($relPath)) {
        Write-Host "  Bundling $relPath..."
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $b64 = [System.Convert]::ToBase64String($bytes)
        $ext = $file.Extension.TrimStart(".")
        
        $mime = "image/$ext"
        if ($ext -eq "svg") { $mime = "image/svg+xml" }
        if ($ext -eq "glb") { $mime = "model/gltf-binary" }
        if ($ext -eq "jpg") { $mime = "image/jpeg" }
        
        $dataUri = "data:$mime;base64,$b64"
        $jsonStr = $jsonStr.Replace($relPath, $dataUri)
    }
}

# 4. Inject Data and Patch Logic
Write-Host "Injecting Data and Patching HTML..."

$injection = "<script>const BUNDLED_GAME_DATA = $jsonStr;</script>"
$htmlContent = $htmlContent.Replace("</title>", "</title>`n$injection")

# Patch DataLoader.loadJSON
$patchSearch = "async loadJSON(path) {"
$patchReplace = "async loadJSON(path) { if (typeof BUNDLED_GAME_DATA !== 'undefined' && BUNDLED_GAME_DATA[path]) { return BUNDLED_GAME_DATA[path]; }"

if ($htmlContent.Contains($patchSearch)) {
    $htmlContent = $htmlContent.Replace($patchSearch, $patchReplace)
    Write-Host "  DataLoader patched."
}
else {
    Write-Warning "  Could not find DataLoader.loadJSON signature to patch!"
}

# Patch Robustness: Ensure we validate data before using it, preventing crashes on empty objects
# Original: const jsonLoaded = monstersData && weaponsData;
# New: const jsonLoaded = monstersData && monstersData.monsters && weaponsData && weaponsData.weapons;

$robustSearch = "const jsonLoaded = monstersData && weaponsData;"
$robustReplace = "const jsonLoaded = monstersData && monstersData.monsters && weaponsData && weaponsData.weapons;"

if ($htmlContent.Contains($robustSearch)) {
    $htmlContent = $htmlContent.Replace($robustSearch, $robustReplace)
    Write-Host "  Robustness check patched."
}
else {
    # Try finding with whitespace just in case
    Write-Warning "  Could not patch jsonLoaded check. Searching fuzzier..."
}

# 5. Save
Write-Host "Saving to $outputFile..."
$htmlContent | Set-Content -Path $outputFile -Encoding UTF8

Write-Host "Bundle Complete!"
