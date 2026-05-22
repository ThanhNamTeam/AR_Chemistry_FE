param(
    [string]$UnityProjectPath = "D:\Project 2026\Unity Project\Clone\My project-2026-05-19-13-56-49-2026-05-19-13-56-50",
    [string]$SceneRelativePath = "Assets\Scenes\SampleScene.unity",
    [string]$OutputPath = "D:\Project 2026\Flutter Project\EXE201\AR_Chemistry_FE\logs\unity_scene_weight_report_latest.md"
)

$ErrorActionPreference = "Stop"

function Count-Pattern {
    param([string]$Text, [string]$Pattern)
    return ([regex]::Matches($Text, $Pattern)).Count
}

function Format-Size {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}

function Get-FolderSize {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return [pscustomobject]@{ Count = 0; Bytes = 0 }
    }

    $files = Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue
    $sum = ($files | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $sum) { $sum = 0 }
    return [pscustomobject]@{ Count = @($files).Count; Bytes = [long]$sum }
}

function Get-AssetStats {
    param([string]$AssetsPath, [string[]]$Extensions)
    $files = Get-ChildItem -LiteralPath $AssetsPath -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $Extensions -contains $_.Extension.ToLowerInvariant() }
    $sum = ($files | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $sum) { $sum = 0 }

    return [pscustomobject]@{
        Count = @($files).Count
        Bytes = [long]$sum
        Largest = @($files | Sort-Object Length -Descending | Select-Object -First 12 FullName, Length, Extension)
    }
}

function Add-Suspect {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$Area,
        [string]$Impact,
        [string]$Suggestion,
        [string]$Risk
    )
    $List.Add([pscustomobject]@{
        Area = $Area
        Impact = $Impact
        Suggestion = $Suggestion
        Risk = $Risk
    }) | Out-Null
}

$scenePath = Join-Path $UnityProjectPath $SceneRelativePath
$assetsPath = Join-Path $UnityProjectPath "Assets"
$packagesManifestPath = Join-Path $UnityProjectPath "Packages\manifest.json"
$vuforiaConfigPath = Join-Path $UnityProjectPath "Assets\Resources\VuforiaConfiguration.asset"

if (-not (Test-Path -LiteralPath $scenePath)) {
    throw "Scene not found: $scenePath"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputPath) | Out-Null

$sceneText = Get-Content -LiteralPath $scenePath -Raw
$sceneFile = Get-Item -LiteralPath $scenePath

$counts = [ordered]@{
    GameObject = Count-Pattern $sceneText "--- !u!1\b"
    MonoBehaviour = Count-Pattern $sceneText "--- !u!114\b"
    Transform = Count-Pattern $sceneText "--- !u!4\b"
    RectTransform = Count-Pattern $sceneText "--- !u!224\b"
    Camera = Count-Pattern $sceneText "--- !u!20\b"
    Light = Count-Pattern $sceneText "--- !u!108\b"
    Canvas = Count-Pattern $sceneText "--- !u!223\b"
    ParticleSystem = Count-Pattern $sceneText "--- !u!198\b"
    ParticleSystemRenderer = Count-Pattern $sceneText "--- !u!199\b"
    MeshRenderer = Count-Pattern $sceneText "--- !u!23\b"
    SkinnedMeshRenderer = Count-Pattern $sceneText "--- !u!137\b"
    SpriteRenderer = Count-Pattern $sceneText "--- !u!212\b"
    MeshFilter = Count-Pattern $sceneText "--- !u!33\b"
    Animator = Count-Pattern $sceneText "--- !u!95\b"
    Rigidbody3D = Count-Pattern $sceneText "--- !u!54\b"
    Collider3D = (Count-Pattern $sceneText "--- !u!64\b") + (Count-Pattern $sceneText "--- !u!65\b") + (Count-Pattern $sceneText "--- !u!135\b") + (Count-Pattern $sceneText "--- !u!136\b")
    AudioSource = Count-Pattern $sceneText "--- !u!82\b"
    ActiveObjects = Count-Pattern $sceneText "m_IsActive: 1"
    InactiveObjects = Count-Pattern $sceneText "m_IsActive: 0"
    VuforiaMentions = Count-Pattern $sceneText "Vuforia|ObserverBehaviour|ImageTarget|DefaultObserverEventHandler"
}

$assetStats = [ordered]@{
    Textures = Get-AssetStats $assetsPath @(".png", ".jpg", ".jpeg", ".tga", ".tif", ".tiff", ".psd", ".exr", ".hdr")
    Models = Get-AssetStats $assetsPath @(".fbx", ".obj", ".blend", ".dae", ".3ds")
    Materials = Get-AssetStats $assetsPath @(".mat")
    Shaders = Get-AssetStats $assetsPath @(".shader", ".shadergraph", ".shadervariants", ".compute")
    Prefabs = Get-AssetStats $assetsPath @(".prefab")
    Audio = Get-AssetStats $assetsPath @(".wav", ".mp3", ".ogg", ".aiff")
    Video = Get-AssetStats $assetsPath @(".mp4", ".mov", ".webm")
}

$resources = Get-FolderSize (Join-Path $assetsPath "Resources")
$streamingAssets = Get-FolderSize (Join-Path $assetsPath "StreamingAssets")
$textMeshProExamples = Get-FolderSize (Join-Path $assetsPath "TextMesh Pro\Examples & Extras")
$vefects = Get-FolderSize (Join-Path $assetsPath "Vefects")
$labEnv = Get-FolderSize (Join-Path $assetsPath "3D Laboratory Environment with Appratus")

$largeFiles = Get-ChildItem -LiteralPath $assetsPath -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -ge 5MB -and $_.Extension.ToLowerInvariant() -ne ".meta" } |
    Sort-Object Length -Descending |
    Select-Object -First 25 FullName, Length, Extension

$guidToAssetPath = @{}
Get-ChildItem -LiteralPath $assetsPath -Recurse -File -Filter "*.meta" -Force -ErrorAction SilentlyContinue |
    ForEach-Object {
        $metaText = Get-Content -LiteralPath $_.FullName -TotalCount 8 -ErrorAction SilentlyContinue
        $guidLine = $metaText | Where-Object { $_ -match "^guid:\s*([a-f0-9]{32})" } | Select-Object -First 1
        if ($guidLine -match "^guid:\s*([a-f0-9]{32})") {
            $assetPath = $_.FullName -replace "\.meta$", ""
            if (Test-Path -LiteralPath $assetPath) {
                $guidToAssetPath[$Matches[1]] = $assetPath
            }
        }
    }

$sceneGuids = [regex]::Matches($sceneText, "guid:\s*([a-f0-9]{32})") |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique

$sceneDirectRefs = @(
    foreach ($guid in $sceneGuids) {
        if ($guidToAssetPath.ContainsKey($guid)) {
            $asset = Get-Item -LiteralPath $guidToAssetPath[$guid] -ErrorAction SilentlyContinue
            if ($null -ne $asset) {
                [pscustomobject]@{
                    Guid = $guid
                    FullName = $asset.FullName
                    Length = [long]$asset.Length
                    Extension = $asset.Extension.ToLowerInvariant()
                }
            }
        }
    }
)

$sceneDirectRefBytes = ($sceneDirectRefs | Measure-Object -Property Length -Sum).Sum
if ($null -eq $sceneDirectRefBytes) { $sceneDirectRefBytes = 0 }
$sceneDirectRefByType = $sceneDirectRefs |
    Group-Object Extension |
    Sort-Object Count -Descending |
    ForEach-Object {
        $sum = ($_.Group | Measure-Object -Property Length -Sum).Sum
        if ($null -eq $sum) { $sum = 0 }
        [pscustomobject]@{
            Extension = if ([string]::IsNullOrWhiteSpace($_.Name)) { "(none)" } else { $_.Name }
            Count = $_.Count
            Bytes = [long]$sum
        }
    }

$textureMetaLarge = Get-ChildItem -LiteralPath $assetsPath -Recurse -File -Filter "*.meta" -Force -ErrorAction SilentlyContinue |
    Where-Object {
        $text = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
        $text -match "maxTextureSize:\s*(2048|4096|8192)"
    } |
    Select-Object -First 25 FullName

$packageSummary = "manifest.json not found"
if (Test-Path -LiteralPath $packagesManifestPath) {
    $packageText = Get-Content -LiteralPath $packagesManifestPath -Raw
    $packageSummary = ($packageText | ConvertFrom-Json).dependencies.PSObject.Properties |
        Sort-Object Name |
        ForEach-Object { "- $($_.Name): $($_.Value)" }
}

$vuforiaSummary = @()
if (Test-Path -LiteralPath $vuforiaConfigPath) {
    $vuforiaText = Get-Content -LiteralPath $vuforiaConfigPath -Raw
    $vuforiaSummary += "- VuforiaConfiguration.asset exists"
    $vuforiaSummary += "- autoStartTracker: $((Select-String -InputObject $vuforiaText -Pattern 'autoStartTracker:\s*(\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', ')"
    $vuforiaSummary += "- delayedInitialization: $((Select-String -InputObject $vuforiaText -Pattern 'delayedInitialization:\s*(\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }) -join ', ')"
    $vuforiaSummary += "- version: $((Select-String -InputObject $vuforiaText -Pattern 'version:\s*([^\r\n]+)' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() }) -join ', ')"
} else {
    $vuforiaSummary += "- VuforiaConfiguration.asset not found"
}

$suspects = [System.Collections.Generic.List[object]]::new()

if ($counts.GameObject -gt 120 -or $counts.MeshRenderer -gt 80 -or $counts.SkinnedMeshRenderer -gt 10) {
    Add-Suspect $suspects "Scene object count" "More active renderers/objects increase scene activation and first render time." "Split scanner boot into tiny BootScene plus lazy-enable chemistry/result objects after Vuforia is ready." "Medium: moving objects between scenes/prefabs needs reference validation."
}
if ($counts.ParticleSystem -gt 10 -or $vefects.Bytes -gt 20MB) {
    Add-Suspect $suspects "VFX/particle assets" "URP/VFX shaders can trigger expensive variant compilation and first-use stalls." "Pool VFX, disable non-scanner VFX at startup, and keep shader variants in the preloaded collection." "Low to medium: visual timing may change."
}
if ($assetStats.Textures.Bytes -gt 100MB -or @($textureMetaLarge).Count -gt 0) {
    Add-Suspect $suspects "Large textures" "Large 2K/4K textures inflate import/build size and cold decompression time." "Downscale optional textures, use platform override compression, and load non-scanner models later." "Medium: visual quality may change."
}
if ($assetStats.Models.Bytes -gt 500MB -or $labEnv.Bytes -gt 500MB) {
    Add-Suspect $suspects "Large model library" "The project contains very large FBX/model assets that can become expensive if referenced by the scanner scene or prefabs." "Keep only scanner-critical models referenced at startup; move optional chemistry/result models to a lazy-loaded scene, Addressables, or AssetBundles." "Medium to high: references and prefab loading paths need validation."
}
if ($sceneDirectRefBytes -gt 100MB) {
    Add-Suspect $suspects "Direct SampleScene references" "SampleScene directly references a large asset footprint, so scene activation can wait on heavy model/texture dependencies." "Split direct heavy references out of SampleScene or instantiate them only after Vuforia camera readiness." "Medium: scene/prefab references must be preserved."
}
if ($resources.Bytes -gt 50MB) {
    Add-Suspect $suspects "Resources folder" "Resources content is hard to strip and often increases memory/build load." "Move optional content from Resources to Addressables/AssetBundles or scene references loaded on demand." "Medium: loading code changes required."
}
if ($streamingAssets.Bytes -gt 50MB) {
    Add-Suspect $suspects "StreamingAssets" "Large StreamingAssets are packaged directly and can slow install/cold access." "Keep only Vuforia-required datasets and truly streaming files here." "Medium: validate Vuforia database paths."
}
if ($textMeshProExamples.Bytes -gt 0) {
    Add-Suspect $suspects "TextMesh Pro examples" "Examples can leak unused assets into project references or build if referenced." "Verify no scene/prefab references examples; remove only after backup if unused." "Low: safe if references are clean."
}
if ($counts.VuforiaMentions -eq 0) {
    Add-Suspect $suspects "Vuforia scene references" "No Vuforia references in SampleScene would mean camera/targets cannot initialize from scene." "Verify ARCamera/VuforiaBehaviour and ImageTarget objects are in SampleScene." "Low: inspection only."
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Unity Scene Weight Report") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
$lines.Add("- Unity project: ``$UnityProjectPath``") | Out-Null
$lines.Add("- Scene: ``$SceneRelativePath``") | Out-Null
$lines.Add("- Scene file size: $(Format-Size $sceneFile.Length)") | Out-Null
$lines.Add("- Mode: read-only audit; no scene or asset mutation") | Out-Null
$lines.Add("") | Out-Null

$lines.Add("## Scene Object Counts") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("| Item | Count |") | Out-Null
$lines.Add("| --- | ---: |") | Out-Null
foreach ($key in $counts.Keys) {
    $lines.Add("| $key | $($counts[$key]) |") | Out-Null
}
$lines.Add("") | Out-Null

$lines.Add("## Asset Footprint") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("| Type | Count | Total Size |") | Out-Null
$lines.Add("| --- | ---: | ---: |") | Out-Null
foreach ($key in $assetStats.Keys) {
    $stat = $assetStats[$key]
    $lines.Add("| $key | $($stat.Count) | $(Format-Size $stat.Bytes) |") | Out-Null
}
$lines.Add("| Resources folder | $($resources.Count) | $(Format-Size $resources.Bytes) |") | Out-Null
$lines.Add("| StreamingAssets folder | $($streamingAssets.Count) | $(Format-Size $streamingAssets.Bytes) |") | Out-Null
$lines.Add("| TextMesh Pro Examples & Extras | $($textMeshProExamples.Count) | $(Format-Size $textMeshProExamples.Bytes) |") | Out-Null
$lines.Add("| Vefects folder | $($vefects.Count) | $(Format-Size $vefects.Bytes) |") | Out-Null
$lines.Add("| Lab environment folder | $($labEnv.Count) | $(Format-Size $labEnv.Bytes) |") | Out-Null
$lines.Add("") | Out-Null

$lines.Add("## Large Files") | Out-Null
$lines.Add("") | Out-Null
if (@($largeFiles).Count -eq 0) {
    $lines.Add("- No files >= 5 MB found under Assets.") | Out-Null
} else {
    foreach ($file in $largeFiles) {
        $rel = $file.FullName.Substring($UnityProjectPath.Length + 1)
        $lines.Add("- $(Format-Size $file.Length) ``$rel``") | Out-Null
    }
}
$lines.Add("") | Out-Null

$lines.Add("## Direct SampleScene Asset References") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("- Direct referenced assets: $(@($sceneDirectRefs).Count)") | Out-Null
$lines.Add("- Direct referenced file bytes: $(Format-Size $sceneDirectRefBytes)") | Out-Null
$lines.Add("") | Out-Null
if (@($sceneDirectRefByType).Count -gt 0) {
    $lines.Add("| Extension | Count | Total Size |") | Out-Null
    $lines.Add("| --- | ---: | ---: |") | Out-Null
    foreach ($entry in $sceneDirectRefByType) {
        $lines.Add("| $($entry.Extension) | $($entry.Count) | $(Format-Size $entry.Bytes) |") | Out-Null
    }
    $lines.Add("") | Out-Null
}

$topSceneRefs = $sceneDirectRefs | Sort-Object Length -Descending | Select-Object -First 20
if (@($topSceneRefs).Count -eq 0) {
    $lines.Add("- No direct scene asset references resolved from GUIDs.") | Out-Null
} else {
    foreach ($ref in $topSceneRefs) {
        $rel = $ref.FullName.Substring($UnityProjectPath.Length + 1)
        $lines.Add("- $(Format-Size $ref.Length) ``$rel``") | Out-Null
    }
}
$lines.Add("") | Out-Null

$lines.Add("## Texture Import Suspects") | Out-Null
$lines.Add("") | Out-Null
if (@($textureMetaLarge).Count -eq 0) {
    $lines.Add("- No texture meta files with maxTextureSize 2048/4096/8192 found in the first scan window.") | Out-Null
} else {
    foreach ($meta in $textureMetaLarge) {
        $assetPath = $meta.FullName -replace "\.meta$", ""
        if (Test-Path -LiteralPath $assetPath) {
            $asset = Get-Item -LiteralPath $assetPath
            $rel = $asset.FullName.Substring($UnityProjectPath.Length + 1)
            $lines.Add("- $(Format-Size $asset.Length) ``$rel``") | Out-Null
        }
    }
}
$lines.Add("") | Out-Null

$lines.Add("## Packages") | Out-Null
$lines.Add("") | Out-Null
if ($packageSummary -is [string]) {
    $lines.Add("- $packageSummary") | Out-Null
} else {
    foreach ($pkg in $packageSummary) { $lines.Add($pkg) | Out-Null }
}
$lines.Add("") | Out-Null

$lines.Add("## Vuforia Config") | Out-Null
$lines.Add("") | Out-Null
foreach ($entry in $vuforiaSummary) { $lines.Add($entry) | Out-Null }
$lines.Add("") | Out-Null

$lines.Add("## Heavy Suspects And Suggestions") | Out-Null
$lines.Add("") | Out-Null
if ($suspects.Count -eq 0) {
    $lines.Add("- No severe scene-weight suspects crossed the built-in thresholds. Continue measuring runtime startup markers before changing content.") | Out-Null
} else {
    $lines.Add("| Area | Impact | Suggested Fix | Risk |") | Out-Null
    $lines.Add("| --- | --- | --- | --- |") | Out-Null
    foreach ($s in $suspects) {
        $lines.Add("| $($s.Area) | $($s.Impact) | $($s.Suggestion) | $($s.Risk) |") | Out-Null
    }
}
$lines.Add("") | Out-Null
$lines.Add("## Next Safe Optimization Order") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("1. Measure first run with BootScene and preloaded shader variants exported.") | Out-Null
$lines.Add("2. If scene activation is still slow, split non-scanner chemistry/result models out of SampleScene or lazy-enable them after Vuforia starts.") | Out-Null
$lines.Add("3. If shader compilation still dominates, capture a runtime ShaderVariantCollection from device/editor playback and replace the generated broad collection.") | Out-Null
$lines.Add("4. If APK/install size dominates, compress/downscale largest textures and move optional content out of Resources.") | Out-Null
$lines.Add("5. Keep Unity mounted once per Flutter app session; Android process kill always requires a new Unity cold start.") | Out-Null

$lines | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "[UNITY_SCENE_AUDIT] Report written to $OutputPath"
