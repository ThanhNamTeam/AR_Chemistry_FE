$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$GradleFile = Join-Path $ProjectRoot 'unityLibrary\build.gradle'
$UnityManifestFile = Join-Path $ProjectRoot 'unityLibrary\src\main\AndroidManifest.xml'
$AppManifestFile = Join-Path $ProjectRoot 'android\app\src\main\AndroidManifest.xml'
$AndroidGradlePropertiesFile = Join-Path $ProjectRoot 'android\gradle.properties'
$UnityGradlePropertiesFile = Join-Path $ProjectRoot 'unityLibrary\gradle.properties'

function Write-Status($Message) {
    Write-Host "[UNITY_EXPORT_PATCH] $Message"
}

function Require-File($Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing required file: $Path"
    }
}

function Save-Utf8NoBom($Path, $Text) {
    $Encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $Encoding)
}

function Get-JavaMajorVersion($JavaExe) {
    if (-not (Test-Path -LiteralPath $JavaExe)) {
        return 0
    }

    $VersionOutput = & cmd.exe /c "`"$JavaExe`" -version 2>&1" | Out-String
    if ($VersionOutput -match 'version "([^"]+)"') {
        $Version = $Matches[1]
        if ($Version.StartsWith('1.')) {
            $Parts = $Version.Split('.')
            if ($Parts.Length -gt 1) {
                return [int]$Parts[1]
            }
        }

        $MajorText = $Version.Split('.')[0]
        return [int]$MajorText
    }

    return 0
}

function Test-Jdk11OrNewer($JdkPath) {
    if ([string]::IsNullOrWhiteSpace($JdkPath)) {
        return $false
    }

    $JavaExe = Join-Path $JdkPath 'bin\java.exe'
    return (Get-JavaMajorVersion $JavaExe) -ge 11
}

function Find-AndroidStudioJbr {
    $Candidates = New-Object System.Collections.Generic.List[string]

    if (-not [string]::IsNullOrWhiteSpace($env:ANDROID_STUDIO_ROOT)) {
        $Candidates.Add((Join-Path $env:ANDROID_STUDIO_ROOT 'jbr'))
    }

    if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
        $Candidates.Add((Join-Path $env:ProgramFiles 'Android\Android Studio\jbr'))
    }

    $ProgramFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
    if (-not [string]::IsNullOrWhiteSpace($ProgramFilesX86)) {
        $Candidates.Add((Join-Path $ProgramFilesX86 'Android\Android Studio\jbr'))
    }

    if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
        $Candidates.Add((Join-Path $env:LOCALAPPDATA 'Programs\Android Studio\jbr'))
    }

    if (-not [string]::IsNullOrWhiteSpace($env:JAVA_HOME)) {
        $Candidates.Add($env:JAVA_HOME)
    }

    foreach ($Candidate in $Candidates) {
        if (Test-Jdk11OrNewer $Candidate) {
            return (Resolve-Path -LiteralPath $Candidate).Path
        }
    }

    throw 'Could not find a JDK 11+ install. Set ANDROID_STUDIO_ROOT to Android Studio, or set JAVA_HOME to a JDK 11+ path.'
}

function Set-GradleJavaHome {
    Require-File $AndroidGradlePropertiesFile
    $JdkPath = (Find-AndroidStudioJbr) -replace '\\', '/'
    $Text = Get-Content -LiteralPath $AndroidGradlePropertiesFile -Raw
    $Line = "org.gradle.java.home=$JdkPath"

    if ($Text -match '(?m)^org\.gradle\.java\.home=') {
        $Text = $Text -replace '(?m)^org\.gradle\.java\.home=.*$', $Line
    } else {
        if (-not $Text.EndsWith("`n")) {
            $Text += "`r`n"
        }
        $Text += "$Line`r`n"
    }

    Save-Utf8NoBom $AndroidGradlePropertiesFile $Text
    Write-Status "Set Android Gradle JDK: $JdkPath"
}

function Test-GradleJavaHomePinned {
    $Text = Get-Content -LiteralPath $AndroidGradlePropertiesFile -Raw
    if ($Text -notmatch '(?m)^org\.gradle\.java\.home=(.+)$') {
        return $false
    }

    $JdkPath = $Matches[1] -replace '/', '\'
    return Test-Jdk11OrNewer $JdkPath
}

function Get-PropertyValue($Text, $Name) {
    $Pattern = '(?m)^' + [regex]::Escape($Name) + '=(.+)$'
    if ($Text -match $Pattern) {
        return $Matches[1].Trim()
    }

    throw "Missing required Gradle property: $Name"
}

function Set-PropertyLine($Text, $Name, $Value) {
    $Line = "$Name=$Value"
    $Pattern = '(?m)^' + [regex]::Escape($Name) + '=.*$'
    if ($Text -match $Pattern) {
        return $Text -replace $Pattern, $Line
    }

    if (-not $Text.EndsWith("`n")) {
        $Text += "`r`n"
    }

    return $Text + "$Line`r`n"
}

function Patch-UnityGradleProperties {
    Require-File $AndroidGradlePropertiesFile
    Require-File $UnityGradlePropertiesFile

    $AndroidText = Get-Content -LiteralPath $AndroidGradlePropertiesFile -Raw
    $UnityText = Get-Content -LiteralPath $UnityGradlePropertiesFile -Raw

    foreach ($Name in @('unity.androidSdkPath', 'unity.androidNdkPath', 'unity.androidNdkVersion')) {
        $UnityText = Set-PropertyLine $UnityText $Name (Get-PropertyValue $AndroidText $Name)
    }

    Save-Utf8NoBom $UnityGradlePropertiesFile $UnityText
    Write-Status 'Patched unityLibrary/gradle.properties Android SDK/NDK paths'
}

function Patch-Gradle {
    Require-File $GradleFile
    $Text = Get-Content -LiteralPath $GradleFile -Raw

    $Text = $Text -replace "implementation fileTree\(dir: 'libs', include: \['\*\.jar'\]\)", "implementation fileTree(dir: 'libs', include: ['*.jar'], exclude: ['unity-classes.jar'])"

    if ($Text -notmatch "compileOnly\s+files\('libs/unity-classes\.jar'\)") {
        $Text = $Text -replace "(implementation fileTree\(dir: 'libs', include: \['\*\.jar'\], exclude: \['unity-classes\.jar'\]\)\r?\n)", "`$1    compileOnly files('libs/unity-classes.jar')`r`n"
    }

    $Text = $Text -replace 'ndkPath\s+"[^"]+"', 'ndkPath project.property("unity.androidNdkPath").toString()'
    $Text = $Text -replace 'ndkVersion\s+"[^"]+"', 'ndkVersion project.property("unity.androidNdkVersion").toString()'
    $Text = $Text -replace '(?m)^\s*commandLineArgs\.add\("--profiler-report"\)\s*\r?\n', ''
    $Text = $Text -replace '(?m)^\s*commandLineArgs\.add\("--profiler-output-file=[^"]+"\)\s*\r?\n', ''
    $Text = $Text -replace '\)(\s+)commandLineArgs\.add\(', ")`r`n    commandLineArgs.add("
    $Text = $Text -replace 'commandLineArgs\.add\("--tool-chain-path="\s*\+\s*getProperty\("unity\.androidNdkPath"\)\)', 'commandLineArgs.add("--tool-chain-path=" + project.property("unity.androidNdkPath").toString())'
    $Text = $Text -replace 'getProperty\("unity\.androidSdkPath"\)', 'project.property("unity.androidSdkPath").toString()'
    $Text = $Text -replace 'getProperty\("unity\.androidNdkPath"\)', 'project.property("unity.androidNdkPath").toString()'

    Save-Utf8NoBom $GradleFile $Text
    Write-Status 'Patched unityLibrary/build.gradle'
}

function Ensure-Feature($ManifestPath, $FeatureName) {
    $Text = Get-Content -LiteralPath $ManifestPath -Raw
    if ($Text -match [regex]::Escape("android:name=`"$FeatureName`"")) {
        return
    }

    $FeatureLine = "    <uses-feature android:name=`"$FeatureName`" android:required=`"false`"/>"
    $Text = $Text -replace '(<application\b)', "$FeatureLine`r`n    `$1"
    Save-Utf8NoBom $ManifestPath $Text
}

function Patch-AppManifest {
    Require-File $AppManifestFile
    Ensure-Feature $AppManifestFile 'android.hardware.camera'
    Ensure-Feature $AppManifestFile 'android.hardware.camera.autofocus'
    Ensure-Feature $AppManifestFile 'android.hardware.camera.front'
    Write-Status 'Verified Flutter app camera feature declarations'
}

function Patch-UnityManifest {
    Require-File $UnityManifestFile
    [xml]$Xml = Get-Content -LiteralPath $UnityManifestFile -Raw
    $AndroidNs = 'http://schemas.android.com/apk/res/android'
    $Application = $Xml.manifest.application
    $Removed = 0

    @($Application.activity) | ForEach-Object {
        if ($_ -eq $null) {
            return
        }

        $ActivityName = $_.GetAttribute('name', $AndroidNs)
        $HasLauncher = $false
        foreach ($Filter in @($_.'intent-filter')) {
            if ($Filter -eq $null) {
                continue
            }

            $HasMain = $false
            $HasLauncherCategory = $false
            foreach ($Action in @($Filter.action)) {
                if ($Action.GetAttribute('name', $AndroidNs) -eq 'android.intent.action.MAIN') {
                    $HasMain = $true
                }
            }
            foreach ($Category in @($Filter.category)) {
                if ($Category.GetAttribute('name', $AndroidNs) -eq 'android.intent.category.LAUNCHER') {
                    $HasLauncherCategory = $true
                }
            }
            if ($HasMain -and $HasLauncherCategory) {
                $HasLauncher = $true
            }
        }

        if ($ActivityName -eq 'com.unity3d.player.UnityPlayerActivity' -or $HasLauncher) {
            [void]$Application.RemoveChild($_)
            $Removed++
        }
    }

    $WriterSettings = New-Object System.Xml.XmlWriterSettings
    $WriterSettings.Encoding = New-Object System.Text.UTF8Encoding($false)
    $WriterSettings.Indent = $true
    $WriterSettings.OmitXmlDeclaration = $false
    $Writer = [System.Xml.XmlWriter]::Create($UnityManifestFile, $WriterSettings)
    try {
        $Xml.Save($Writer)
    } finally {
        $Writer.Close()
    }

    Write-Status "Stripped Unity standalone launcher activities: $Removed"
}

function Test-PatchState {
    $GradleText = Get-Content -LiteralPath $GradleFile -Raw
    $UnityManifestText = Get-Content -LiteralPath $UnityManifestFile -Raw
    $AppManifestText = Get-Content -LiteralPath $AppManifestFile -Raw
    $AndroidGradlePropertiesText = Get-Content -LiteralPath $AndroidGradlePropertiesFile -Raw
    $UnityGradlePropertiesText = Get-Content -LiteralPath $UnityGradlePropertiesFile -Raw
    $PinnedUnityNdkPath = Get-PropertyValue $AndroidGradlePropertiesText 'unity.androidNdkPath'
    $PinnedUnityNdkVersion = Get-PropertyValue $AndroidGradlePropertiesText 'unity.androidNdkVersion'

    $Checks = @(
        @{ Name = 'unity-classes.jar excluded from runtime fileTree'; Ok = $GradleText -match "exclude:\s*\['unity-classes\.jar'\]" },
        @{ Name = 'unity-classes.jar added as compileOnly'; Ok = $GradleText -match "compileOnly\s+files\('libs/unity-classes\.jar'\)" },
        @{ Name = 'NDK path comes from Gradle property'; Ok = $GradleText -match 'ndkPath\s+project\.property\("unity\.androidNdkPath"\)\.toString\(\)' },
        @{ Name = 'NDK version comes from Gradle property'; Ok = $GradleText -match 'ndkVersion\s+project\.property\("unity\.androidNdkVersion"\)\.toString\(\)' },
        @{ Name = 'Unity library Gradle NDK path matches pinned Unity NDK'; Ok = (Get-PropertyValue $UnityGradlePropertiesText 'unity.androidNdkPath') -eq $PinnedUnityNdkPath },
        @{ Name = 'Unity library Gradle NDK version matches pinned Unity NDK'; Ok = (Get-PropertyValue $UnityGradlePropertiesText 'unity.androidNdkVersion') -eq $PinnedUnityNdkVersion },
        @{ Name = 'IL2CPP profiler args removed'; Ok = $GradleText -notmatch '--profiler-report|--profiler-output-file' },
        @{ Name = 'Unity standalone launcher activity removed'; Ok = $UnityManifestText -notmatch 'UnityPlayerActivity|android\.intent\.action\.MAIN|android\.intent\.category\.LAUNCHER' },
        @{ Name = 'Flutter app manifest declares camera feature'; Ok = $AppManifestText -match 'android\.hardware\.camera' },
        @{ Name = 'Flutter app manifest declares autofocus feature'; Ok = $AppManifestText -match 'android\.hardware\.camera\.autofocus' },
        @{ Name = 'Android Gradle JDK pinned to JDK 11+'; Ok = Test-GradleJavaHomePinned }
    )

    $Failed = $Checks | Where-Object { -not $_.Ok }
    foreach ($Check in $Checks) {
        $State = if ($Check.Ok) { 'OK' } else { 'FAIL' }
        Write-Status "$State - $($Check.Name)"
    }

    if ($Failed.Count -gt 0) {
        throw "Unity export patch failed $($Failed.Count) checks."
    }
}

Set-Location $ProjectRoot
Set-GradleJavaHome
Patch-UnityGradleProperties
Patch-Gradle
Patch-AppManifest
Patch-UnityManifest
Test-PatchState
