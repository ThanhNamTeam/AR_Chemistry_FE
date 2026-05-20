param(
    [switch]$SkipBuildCheck
)

$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$GradleFile = Join-Path $ProjectRoot 'unityLibrary\build.gradle'
$PatchScript = Join-Path $PSScriptRoot 'patch_unity_export.ps1'
$LogDir = Join-Path $ProjectRoot 'logs'
$LogPath = Join-Path $LogDir 'ar_unity_diag_latest.log'
$BuildCheckLogPath = Join-Path $LogDir 'ar_unity_build_check_latest.log'
$Pattern = 'AR_UNITY_TIMING|ANDROID_HOST_DIAG|UNITY_MANAGED_PROBE|UNITY_PRESCENE_WATCHDOG|UNITY_BOOT_PROBE|UNITY_LOG_BRIDGE|UNITY_CAMERA_DIAG|UNITY_RUNTIME|UNITY_SCANNER|Vuforia|cameraDevice|targetStatus|unitySceneLoaded|dispose|Exception|Error|AndroidRuntime|FATAL'

Set-Location $ProjectRoot
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

if (-not (Test-Path -LiteralPath $GradleFile)) {
    Write-Error "Missing unityLibrary\build.gradle. Export/copy Unity Android Library first."
    exit 1
}

function Write-BuildCheck($Message) {
    $Line = "[AR_UNITY_BUILD_CHECK] $Message"
    Write-Host $Line
    Add-Content -LiteralPath $BuildCheckLogPath -Value $Line
}

function Assert-Check($Name, $Ok) {
    if ($Ok) {
        Write-BuildCheck "OK - $Name"
        return
    }

    Write-BuildCheck "FAIL - $Name"
    throw "Build check failed: $Name"
}

function Get-MergedManifestPath {
    $Candidates = Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'build\app\intermediates') -Recurse -Filter 'AndroidManifest.xml' -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -match 'merged' -and $_.FullName -match 'processDebugMainManifest'
        } |
        Sort-Object LastWriteTime -Descending

    if ($Candidates.Count -gt 0) {
        return $Candidates[0].FullName
    }

    return $null
}

function Test-MergedManifest {
    $ManifestPath = Get-MergedManifestPath
    Assert-Check 'merged debug manifest exists' ($null -ne $ManifestPath)
    Write-BuildCheck "merged manifest path=$ManifestPath"

    [xml]$Xml = Get-Content -LiteralPath $ManifestPath -Raw
    $AndroidNs = 'http://schemas.android.com/apk/res/android'
    $LauncherActivities = @()
    foreach ($Activity in @($Xml.manifest.application.activity)) {
        foreach ($Filter in @($Activity.'intent-filter')) {
            if ($Filter -eq $null) {
                continue
            }

            $HasMain = $false
            $HasLauncher = $false
            foreach ($Action in @($Filter.action)) {
                if ($Action.GetAttribute('name', $AndroidNs) -eq 'android.intent.action.MAIN') {
                    $HasMain = $true
                }
            }
            foreach ($Category in @($Filter.category)) {
                if ($Category.GetAttribute('name', $AndroidNs) -eq 'android.intent.category.LAUNCHER') {
                    $HasLauncher = $true
                }
            }
            if ($HasMain -and $HasLauncher) {
                $LauncherActivities += $Activity.GetAttribute('name', $AndroidNs)
            }
        }
    }

    Write-BuildCheck "launcher activities=$($LauncherActivities -join ',')"
    Assert-Check 'merged manifest has exactly one launcher activity' ($LauncherActivities.Count -eq 1)
    Assert-Check 'launcher activity is Flutter MainActivity' ($LauncherActivities[0] -eq 'com.example.ar_chemistry_visual.MainActivity')
}

function Test-ApkContents {
    $ApkPath = Join-Path $ProjectRoot 'build\app\outputs\flutter-apk\app-debug.apk'
    Assert-Check 'debug APK exists' (Test-Path -LiteralPath $ApkPath)
    Write-BuildCheck "apk path=$ApkPath"

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $Zip = [System.IO.Compression.ZipFile]::OpenRead($ApkPath)
    try {
        $EntryNames = @($Zip.Entries | ForEach-Object { $_.FullName })
    } finally {
        $Zip.Dispose()
    }

    Assert-Check 'APK contains Unity data.unity3d' ($EntryNames -contains 'assets/bin/Data/data.unity3d')
    Assert-Check 'APK contains libmain.so' ($EntryNames -contains 'lib/arm64-v8a/libmain.so')
    Assert-Check 'APK contains libunity.so' ($EntryNames -contains 'lib/arm64-v8a/libunity.so')
    Assert-Check 'APK contains libil2cpp.so' ($EntryNames -contains 'lib/arm64-v8a/libil2cpp.so')
    Assert-Check 'Unity export contains VuforiaEngine.aar' (Test-Path -LiteralPath (Join-Path $ProjectRoot 'unityLibrary\libs\VuforiaEngine.aar'))
}

function Invoke-FlutterCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$OnLine
    )

    $PreviousErrorActionPreference = $ErrorActionPreference
    $global:LASTEXITCODE = 0
    try {
        $ErrorActionPreference = 'Continue'
        & flutter @Arguments 2>&1 | ForEach-Object {
            & $OnLine $_.ToString()
        }
        $ExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $PreviousErrorActionPreference
    }

    return $ExitCode
}

Set-Content -LiteralPath $BuildCheckLogPath -Value "[AR_UNITY_BUILD_CHECK] Started $(Get-Date -Format o)"

if (-not (Test-Path -LiteralPath $PatchScript)) {
    Write-Error "Missing post-export patch script: $PatchScript"
    exit 1
}

Write-BuildCheck 'Applying post-export Unity patch'
& $PatchScript 2>&1 | ForEach-Object {
    $Line = $_.ToString()
    Write-Host $Line
    Add-Content -LiteralPath $BuildCheckLogPath -Value $Line
}

$GradleText = Get-Content -LiteralPath $GradleFile -Raw
$Checks = @(
    @{
        Name = 'unity-classes.jar excluded from implementation fileTree'
        Ok = $GradleText -match "exclude:\s*\['unity-classes\.jar'\]"
    },
    @{
        Name = 'unity-classes.jar added as compileOnly'
        Ok = $GradleText -match "compileOnly\s+files\('libs/unity-classes\.jar'\)"
    },
    @{
        Name = 'NDK path comes from Gradle property'
        Ok = $GradleText -match 'ndkPath\s+project\.property\("unity\.androidNdkPath"\)\.toString\(\)'
    },
    @{
        Name = 'IL2CPP profiler args removed'
        Ok = $GradleText -notmatch '--profiler-report|--profiler-output-file'
    }
)

$FailedChecks = $Checks | Where-Object { -not $_.Ok }
if ($FailedChecks.Count -gt 0) {
    Write-Host 'Unity Gradle export patch is missing:' -ForegroundColor Yellow
    $FailedChecks | ForEach-Object { Write-Host " - $($_.Name)" -ForegroundColor Yellow }
    Write-Host 'Ask Codex: patch gradle' -ForegroundColor Yellow
    exit 1
}

if (-not $SkipBuildCheck) {
    Write-BuildCheck 'Running flutter build apk --debug --no-pub for manifest/APK verification'
    $BuildExitCode = Invoke-FlutterCommand -Arguments @('build', 'apk', '--debug', '--no-pub') -OnLine {
        param($Line)
        if ($Line -match 'Built build\\app\\outputs\\flutter-apk\\app-debug.apk|FAILURE|ERROR|Exception|Execution failed') {
            Write-Host $Line
        }
        Add-Content -LiteralPath $BuildCheckLogPath -Value $Line
    }
    Assert-Check 'flutter build apk --debug --no-pub exit code is 0' ($BuildExitCode -eq 0)

    Test-MergedManifest
    Test-ApkContents
} else {
    Write-BuildCheck 'Skipping build/APK verification because -SkipBuildCheck was provided'
}

Write-Host "Running Flutter Unity diagnostics from $ProjectRoot" -ForegroundColor Cyan
Write-Host "Filtered log will be saved to $LogPath" -ForegroundColor Cyan
Write-Host "Build checks saved to $BuildCheckLogPath" -ForegroundColor Cyan
Write-Host 'Open AR Scanner after the app launches. Press q in flutter run when finished.' -ForegroundColor Cyan

$RunLines = New-Object System.Collections.Generic.List[string]
$RunExitCode = Invoke-FlutterCommand -Arguments @('run', '--no-pub') -OnLine {
    param($Line)
    if ($Line -match $Pattern) {
        $Line
        $RunLines.Add($Line)
    }
}
$RunLines | Set-Content -LiteralPath $LogPath
if ($RunExitCode -ne 0) {
    Write-BuildCheck "flutter run --no-pub exited with code $RunExitCode"
}
