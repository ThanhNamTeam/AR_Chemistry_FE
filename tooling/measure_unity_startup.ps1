param(
    [int]$LogcatSeconds = 180,
    [switch]$SkipFlutterRun
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $repoRoot "build"
$logFile = Join-Path $buildDir "unity-startup-logcat.txt"
$summaryFile = Join-Path $buildDir "unity-startup-summary.txt"

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$adb = "adb"
$localProperties = Join-Path $repoRoot "android\local.properties"
if (Test-Path $localProperties) {
    $sdkLine = Get-Content $localProperties | Where-Object { $_ -like "sdk.dir=*" } | Select-Object -First 1
    if ($sdkLine) {
        $sdkDir = $sdkLine.Substring("sdk.dir=".Length)
        $candidate = Join-Path $sdkDir "platform-tools\adb.exe"
        if (Test-Path $candidate) {
            $adb = $candidate
        }
    }
}

& $adb logcat -c

$patterns = @(
    "Unity",
    "Vuforia",
    "ARCore",
    "XRGeneralSettings",
    "libil2cpp",
    "Choreographer",
    "Camera",
    "AR_UNITY_TIMING"
)

$logcatArgs = @("logcat", "-v", "time")
$logcat = Start-Process -FilePath $adb -ArgumentList $logcatArgs -RedirectStandardOutput $logFile -NoNewWindow -PassThru

$startedAt = Get-Date
$runExitCode = $null
$runElapsed = "skipped"
if (-not $SkipFlutterRun) {
    Push-Location $repoRoot
    try {
        $runTimer = [System.Diagnostics.Stopwatch]::StartNew()
        & flutter run --profile
        $runExitCode = $LASTEXITCODE
        $runTimer.Stop()
        $runElapsed = $runTimer.Elapsed.ToString()
    }
    finally {
        Pop-Location
    }
}

Start-Sleep -Seconds $LogcatSeconds

if (-not $logcat.HasExited) {
    Stop-Process -Id $logcat.Id -Force
}

$endedAt = Get-Date
$filtered = Get-Content $logFile | Where-Object {
    $line = $_
    $patterns | Where-Object { $line -match $_ }
}

$filteredFile = Join-Path $buildDir "unity-startup-filtered-logcat.txt"
$filtered | Set-Content $filteredFile

@(
    "Started: $startedAt",
    "Ended: $endedAt",
    "Flutter run exit code: $runExitCode",
    "Flutter run elapsed: $runElapsed",
    "Raw logcat: $logFile",
    "Filtered logcat: $filteredFile",
    "",
    "Open the AR scanner three times and compare AR_UNITY_TIMING routeOpened, unityCreated, unityState, and unitySceneLoaded lines."
) | Set-Content $summaryFile

Get-Content $summaryFile
