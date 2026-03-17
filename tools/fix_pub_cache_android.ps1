[CmdletBinding()]
param(
    [string] $PubCacheRoot = (Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev'),
    [string] $GradleVersion = '8.14',
    [int] $CompileSdkFallback = 34,
    [switch] $ClearGradleScriptCaches = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info([string] $Message) {
    Write-Host "[fix_pub_cache_android] $Message"
}

function Assert-FileExists([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }
}

function Get-Text([string] $Path) {
    Assert-FileExists $Path
    return (Get-Content -LiteralPath $Path -Raw)
}

function Set-Text([string] $Path, [string] $Text) {
    # Preserve UTF-8 without BOM as a safe default.
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

function Ensure-GradleProperty([string] $GradlePropertiesPath, [string] $Key, [string] $Value) {
    $dir = Split-Path -Parent $GradlePropertiesPath
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }

    if (-not (Test-Path -LiteralPath $GradlePropertiesPath)) {
        Set-Text $GradlePropertiesPath "$Key=$Value`r`n"
        Write-Info "Created $GradlePropertiesPath with $Key=$Value"
        return
    }

    $text = Get-Text $GradlePropertiesPath
    if ($text -match "(?m)^\s*${Key}\s*=") {
        # Leave existing value as-is.
        Write-Info "$Key already present ($GradlePropertiesPath)"
        return
    }

    $updated = ($text.TrimEnd() + "`r`n$Key=$Value`r`n")
    Set-Text $GradlePropertiesPath $updated
    Write-Info "Added $Key=$Value ($GradlePropertiesPath)"
}

function Update-GradleWrapperDistributionUrl([string] $WrapperPropertiesPath, [string] $NewGradleVersion) {
    $text = Get-Text $WrapperPropertiesPath
    $newUrl = "https\://services.gradle.org/distributions/gradle-$NewGradleVersion-all.zip"

    if ($text -match '(?m)^distributionUrl=') {
        $updated = [regex]::Replace($text, '(?m)^distributionUrl=.*$', "distributionUrl=$newUrl")
        if ($updated -ne $text) {
            Set-Text $WrapperPropertiesPath $updated
            Write-Info "Updated Gradle wrapper distributionUrl -> $newUrl ($WrapperPropertiesPath)"
        } else {
            Write-Info "Gradle wrapper distributionUrl already set ($WrapperPropertiesPath)"
        }
    } else {
        throw "distributionUrl not found in $WrapperPropertiesPath"
    }
}

function Move-PluginManagement-To-Top([string] $SettingsGradlePath) {
    $text = Get-Text $SettingsGradlePath

    if ($text -notmatch '(?s)pluginManagement\s*\{') {
        Write-Info "No pluginManagement block found; skipping ($SettingsGradlePath)"
        return
    }

    # Extract the first pluginManagement { ... } block (non-nested heuristic; good enough for these files)
    $match = [regex]::Match($text, '(?s)pluginManagement\s*\{.*?\n\}', 'IgnoreCase')
    if (-not $match.Success) {
        throw "Could not parse pluginManagement block in $SettingsGradlePath"
    }

    $pluginMgmt = $match.Value.Trim()
    $rest = ($text.Remove($match.Index, $match.Length)).Trim()

    # If pluginManagement is already first non-empty/non-comment, leave it.
    $leading = $text.TrimStart()
    if ($leading.StartsWith($pluginMgmt)) {
        Write-Info "pluginManagement already at top ($SettingsGradlePath)"
        return
    }

    $newText = $pluginMgmt + "`r`n`r`n" + $rest + "`r`n"
    Set-Text $SettingsGradlePath $newText
    Write-Info "Moved pluginManagement block to top ($SettingsGradlePath)"
}

function Ensure-PluginManagement-Repositories([string] $SettingsGradlePath) {
    $text = Get-Text $SettingsGradlePath
    if ($text -notmatch '(?s)pluginManagement\s*\{') {
        return
    }

    # If a repositories block already exists inside pluginManagement, do nothing.
    if ($text -match '(?s)pluginManagement\s*\{.*?repositories\s*\{') {
        return
    }

    $insertion = @"
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

"@

    $updated = [regex]::Replace(
        $text,
        '(?s)(pluginManagement\s*\{\s*)',
        { param($m) $m.Groups[1].Value + $insertion },
        1
    )

    if ($updated -ne $text) {
        Set-Text $SettingsGradlePath $updated
        Write-Info "Added pluginManagement.repositories ($SettingsGradlePath)"
    }
}

function Fix-FirebaseCore-SettingsGradle([string] $SettingsGradlePath) {
    # firebase_core's settings.gradle currently has rootProject/apply before pluginManagement and uses project.ext.*.
    # For IDE tooling, a simpler, Gradle-8-compatible settings.gradle works better.
    $newText = @"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    plugins {
        id "com.android.application" version "8.3.0"
        id "com.android.library" version "8.3.0"
    }
}

rootProject.name = 'firebase_core'

apply from: file("local-config.gradle")
"@

    $existing = Get-Text $SettingsGradlePath
    if ($existing -ne $newText) {
        Set-Text $SettingsGradlePath $newText
        Write-Info "Rewrote firebase_core settings.gradle into Gradle-8-compatible order ($SettingsGradlePath)"
    } else {
        Write-Info "firebase_core settings.gradle already rewritten ($SettingsGradlePath)"
    }
}

function Fix-FirebaseBuildGradle-Standalone([string] $BuildGradlePath, [string] $AgpVersion, [string] $HeaderKind) {
    # Makes firebase_* plugin Android projects work as standalone roots by ensuring
    # the AGP classpath exists BEFORE `apply plugin: 'com.android.library'`.
    # HeaderKind: 'core' or 'auth'

    $text = Get-Text $BuildGradlePath

    if ($text -notmatch "apply plugin:\s*'com\.android\.library'") {
        Write-Info "No com.android.library apply-plugin found; skipping ($BuildGradlePath)"
        return
    }

    $splitMarker = if ($HeaderKind -eq 'core') { 'def getRootProjectExtOrDefaultProperty' } else { 'allprojects {' }
    $idx = $text.IndexOf($splitMarker)
    if ($idx -lt 0) {
        Write-Info "Could not find expected marker '$splitMarker'; skipping ($BuildGradlePath)"
        return
    }

    $rest = $text.Substring($idx).TrimStart()

    $header = if ($HeaderKind -eq 'core') {
@"
group 'io.flutter.plugins.firebase.core'
version '1.0-SNAPSHOT'

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:$AgpVersion'
    }
}

apply plugin: 'com.android.library'
apply from: file("local-config.gradle")

"@
    } else {
@"
group 'io.flutter.plugins.firebase.auth'
version '1.0-SNAPSHOT'

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:$AgpVersion'
    }
}

apply plugin: 'com.android.library'

"@
    }

    $newText = $header + $rest
    if ($newText -ne $text) {
        Set-Text $BuildGradlePath $newText
        Write-Info "Rewrote firebase build.gradle header for standalone Gradle ($BuildGradlePath)"
    } else {
        Write-Info "firebase build.gradle already rewritten ($BuildGradlePath)"
    }
}

function Patch-FirebaseAuth-Standalone([string] $BuildGradlePath) {
    $text = Get-Text $BuildGradlePath

    # Replace hard-fail when :firebase_core is missing with a soft, standalone-friendly path.
    $start = $text.IndexOf("def firebaseCoreProject = findProject(':firebase_core')")
    if ($start -ge 0) {
        $end = $text.IndexOf('def getRootProjectExtOrCoreProperty', $start)
        if ($end -gt $start) {
            $before = $text.Substring(0, $start)
            $after = $text.Substring($end)

            $insert = @'
def firebaseCoreProject = findProject(':firebase_core')
def firebaseSdkVersion = null
if (firebaseCoreProject != null) {
    firebaseSdkVersion = firebaseCoreProject.properties['FirebaseSDKVersion']
}

'@

            $text = $before + $insert + $after
        }
    }

    # AGP 8+ expects compileSdk; compileSdkVersion may not be recognized.
    $text = [regex]::Replace($text, '(?m)^(\s*)compileSdkVersion\s+(\d+)\s*$', '$1compileSdk $2')

    # Guard standalone sync: don't add null dependencies when firebase_core is not included.
    if ($text -match '(?m)^\s*api\s+firebaseCoreProject\s*$') {
        $apiGuard = @'
if (firebaseSdkVersion != null) {
    api firebaseCoreProject
}
'@

        $text = [regex]::Replace(
            $text,
            '(?m)^(\s*)api\s+firebaseCoreProject\s*$',
            {
                param($m)
                $indent = $m.Groups[1].Value
                ($apiGuard -split "`n" | ForEach-Object { if ($_ -ne '') { $indent + $_.TrimEnd() } else { '' } }) -join "`r`n"
            }
        )
    }

    if ($text -match '(?m)^\s*implementation\s+platform\("com\.google\.firebase:firebase-bom:') {
        $bomGuard = @'
if (firebaseSdkVersion != null) {
    implementation platform("com.google.firebase:firebase-bom:${getRootProjectExtOrCoreProperty("FirebaseSDKVersion", firebaseCoreProject)}")
}
'@

        $text = [regex]::Replace(
            $text,
            '(?m)^(\s*)implementation\s+platform\("com\.google\.firebase:firebase-bom:.*\)\s*$',
            {
                param($m)
                $indent = $m.Groups[1].Value
                ($bomGuard -split "`n" | ForEach-Object { if ($_ -ne '') { $indent + $_.TrimEnd() } else { '' } }) -join "`r`n"
            }
        )
    }

    Set-Text $BuildGradlePath $text
    Write-Info "Patched firebase_auth for standalone sync ($BuildGradlePath)"
}

function Ensure-CompileSdk-Fallback([string] $BuildGradlePath, [int] $FallbackCompileSdk) {
    $text = Get-Text $BuildGradlePath

    if ($text -match 'compileSdk\s*=\s*flutter\.compileSdkVersion' -and $text -notmatch 'compileSdkFallback') {
        $replacement = @"
    def flutterExt = project.extensions.findByName("flutter")
    def compileSdkFallback = $FallbackCompileSdk
    compileSdk = (flutterExt != null) ? flutterExt.compileSdkVersion : compileSdkFallback
"@

        $updated = [regex]::Replace(
            $text,
            '(?m)^(\s*)compileSdk\s*=\s*flutter\.compileSdkVersion\s*$',
            { param($m) $indent = $m.Groups[1].Value; ($replacement -split "`n" | ForEach-Object { if ($_ -ne '') { $indent + $_.TrimEnd() } else { '' } }) -join "`r`n" },
            'IgnoreCase'
        )

        if ($updated -eq $text) {
            throw "Failed to patch compileSdk line in $BuildGradlePath"
        }

        Set-Text $BuildGradlePath $updated
        Write-Info "Patched compileSdk to include fallback ($BuildGradlePath)"
        return
    }

    Write-Info "No compileSdk patch needed ($BuildGradlePath)"
}

function Clear-GradleScriptCache() {
    if (-not $ClearGradleScriptCaches) {
        return
    }

    $gradleHome = Join-Path $env:USERPROFILE '.gradle\caches'
    if (-not (Test-Path -LiteralPath $gradleHome)) {
        Write-Info "No Gradle caches found at $gradleHome"
        return
    }

    $targets = @(
        (Join-Path -Path $gradleHome -ChildPath '8.4\scripts'),
        (Join-Path -Path $gradleHome -ChildPath '8.4\scripts-remapped'),
        (Join-Path -Path $gradleHome -ChildPath '7.4.2\scripts'),
        (Join-Path -Path $gradleHome -ChildPath '7.4.2\scripts-remapped')
    )

    foreach ($t in $targets) {
        if (Test-Path -LiteralPath $t) {
            Remove-Item -LiteralPath $t -Recurse -Force
            Write-Info "Deleted Gradle script cache: $t"
        }
    }
}

Write-Info "Pub cache root: $PubCacheRoot"

# 0) Enable AndroidX globally so any standalone plugin build doesn't warn/fail.
$globalGradleProperties = Join-Path $env:USERPROFILE '.gradle\gradle.properties'
Ensure-GradleProperty $globalGradleProperties 'android.useAndroidX' 'true'

# 1) flutter_secure_storage wrapper Gradle version
$flutterSecureStorageWrapper = Join-Path $PubCacheRoot 'flutter_secure_storage-9.2.4\android\gradle\wrapper\gradle-wrapper.properties'
if (Test-Path -LiteralPath $flutterSecureStorageWrapper) {
    Update-GradleWrapperDistributionUrl $flutterSecureStorageWrapper $GradleVersion
} else {
    Write-Info "flutter_secure_storage wrapper not found (maybe different version?)"
}

# 2) Fix firebase_* settings.gradle ordering
$firebaseCoreSettings = Join-Path $PubCacheRoot 'firebase_core-3.15.2\android\settings.gradle'
if (Test-Path -LiteralPath $firebaseCoreSettings) {
    Fix-FirebaseCore-SettingsGradle $firebaseCoreSettings
    Ensure-PluginManagement-Repositories $firebaseCoreSettings
} else {
    Write-Info "firebase_core settings.gradle not found (maybe different version?)"
}

$firebaseAuthSettings = Join-Path $PubCacheRoot 'firebase_auth-5.7.0\android\settings.gradle'
if (Test-Path -LiteralPath $firebaseAuthSettings) {
    Move-PluginManagement-To-Top $firebaseAuthSettings
    Ensure-PluginManagement-Repositories $firebaseAuthSettings
} else {
    Write-Info "firebase_auth settings.gradle not found (maybe different version?)"
}

# 2b) Make firebase_* standalone android/build.gradle self-contained (AGP classpath before apply plugin)
$firebaseCoreBuildGradle = Join-Path $PubCacheRoot 'firebase_core-3.15.2\android\build.gradle'
if (Test-Path -LiteralPath $firebaseCoreBuildGradle) {
    Fix-FirebaseBuildGradle-Standalone $firebaseCoreBuildGradle '8.3.0' 'core'
} else {
    Write-Info "firebase_core build.gradle not found (maybe different version?)"
}

$firebaseAuthBuildGradle = Join-Path $PubCacheRoot 'firebase_auth-5.7.0\android\build.gradle'
if (Test-Path -LiteralPath $firebaseAuthBuildGradle) {
    Fix-FirebaseBuildGradle-Standalone $firebaseAuthBuildGradle '8.3.0' 'auth'
    Patch-FirebaseAuth-Standalone $firebaseAuthBuildGradle
} else {
    Write-Info "firebase_auth build.gradle not found (maybe different version?)"
}

# 3b) Ensure AndroidX is enabled for plugin standalone builds that complain.
$googleSignInGradleProps = Join-Path $PubCacheRoot 'google_sign_in_android-6.2.1\android\gradle.properties'
Ensure-GradleProperty $googleSignInGradleProps 'android.useAndroidX' 'true'

# 3) compileSdk fallback for standalone builds (safe for app builds too)
$googleSignInBuildGradle = Join-Path $PubCacheRoot 'google_sign_in_android-6.2.1\android\build.gradle'
if (Test-Path -LiteralPath $googleSignInBuildGradle) {
    Ensure-CompileSdk-Fallback $googleSignInBuildGradle $CompileSdkFallback
} else {
    Write-Info "google_sign_in_android build.gradle not found (maybe different version?)"
}

$pathProviderBuildGradle = Join-Path $PubCacheRoot 'path_provider_android-2.2.22\android\build.gradle'
if (Test-Path -LiteralPath $pathProviderBuildGradle) {
    Ensure-CompileSdk-Fallback $pathProviderBuildGradle $CompileSdkFallback
} else {
    Write-Info "path_provider_android build.gradle not found (maybe different version?)"
}

# 4) Clear Gradle caches that may hold old compiled settings scripts
Clear-GradleScriptCache

Write-Info "Done. If Android Studio/VS Code still shows old errors, restart the IDE and re-sync Gradle." 
