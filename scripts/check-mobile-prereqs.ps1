$ErrorActionPreference = "Stop"

$issues = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[object]

function Has-Command {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Add-Issue {
  param(
    [string]$Message,
    [string]$Fix
  )
  $issues.Add([PSCustomObject]@{ Message = $Message; Fix = $Fix }) | Out-Null
}

function Add-Warning {
  param(
    [string]$Message,
    [string]$Fix
  )
  $warnings.Add([PSCustomObject]@{ Message = $Message; Fix = $Fix }) | Out-Null
}

function Path-HasEntry {
  param([string]$Candidate)
  if (-not $Candidate) { return $false }
  $target = [System.IO.Path]::GetFullPath($Candidate).TrimEnd('\')
  $entries = ($env:PATH -split ';') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  foreach ($entry in $entries) {
    try {
      $full = [System.IO.Path]::GetFullPath($entry).TrimEnd('\')
      if ($full -ieq $target) { return $true }
    }
    catch {
      continue
    }
  }
  return $false
}

Write-Host "running mobile environment checks..."

$flutterFound = Has-Command "flutter"
if (-not $flutterFound) {
  Add-Issue `
    "Flutter SDK is not installed or not on PATH (flutter not found)." `
    "Windows: winget install --id Google.Flutter -e`nmacOS: brew install --cask flutter`nLinux: snap install flutter --classic"
}

$javaFound = Has-Command "java"
if (-not $javaFound) {
  Add-Issue `
    "JDK is not installed or not on PATH (java not found)." `
    "Windows: winget install --id EclipseAdoptium.Temurin.17.JDK -e`nmacOS: brew install --cask temurin@17`nLinux (Debian/Ubuntu): sudo apt-get install -y openjdk-17-jdk"
}

if (-not $env:JAVA_HOME) {
  Add-Issue `
    "JAVA_HOME is not set." `
    "PowerShell: setx JAVA_HOME `"<JDK_PATH>`""
}
elseif (-not (Test-Path $env:JAVA_HOME)) {
  Add-Issue `
    "JAVA_HOME points to a missing path: $($env:JAVA_HOME)" `
    "PowerShell: setx JAVA_HOME `"<JDK_PATH>`""
}

$androidSdkPath = $null
if ($env:ANDROID_SDK_ROOT) {
  $androidSdkPath = $env:ANDROID_SDK_ROOT
}
elseif ($env:ANDROID_HOME) {
  $androidSdkPath = $env:ANDROID_HOME
}
else {
  Add-Issue `
    "ANDROID_SDK_ROOT or ANDROID_HOME must be set." `
    "PowerShell (Windows example): setx ANDROID_SDK_ROOT `"$env:LOCALAPPDATA\Android\Sdk`"`nsetx ANDROID_HOME `"$env:LOCALAPPDATA\Android\Sdk`""
}

if ($env:ANDROID_SDK_ROOT -and $env:ANDROID_HOME -and $env:ANDROID_SDK_ROOT -ne $env:ANDROID_HOME) {
  Add-Warning `
    "ANDROID_SDK_ROOT and ANDROID_HOME are different. Consider aligning them." `
    "PowerShell: setx ANDROID_HOME `"$env:ANDROID_SDK_ROOT`""
}

if ($androidSdkPath -and -not (Test-Path $androidSdkPath)) {
  Add-Issue `
    "Android SDK path does not exist: $androidSdkPath" `
    "Create/fix SDK location, then set vars: setx ANDROID_SDK_ROOT `"<actual-sdk-path>`" ; setx ANDROID_HOME `"<actual-sdk-path>`""
}

$sdkmanagerFound = $false
$sdkmanagerPath = $null
if (Has-Command "sdkmanager") {
  $sdkmanagerFound = $true
}
elseif (Has-Command "sdkmanager.bat") {
  $sdkmanagerFound = $true
}
elseif ($androidSdkPath) {
  $candidatePaths = @(
    (Join-Path $androidSdkPath "cmdline-tools\latest\bin\sdkmanager.bat"),
    (Join-Path $androidSdkPath "cmdline-tools\latest\bin\sdkmanager"),
    (Join-Path $androidSdkPath "cmdline-tools\bin\sdkmanager.bat"),
    (Join-Path $androidSdkPath "cmdline-tools\bin\sdkmanager")
  )
  foreach ($candidate in $candidatePaths) {
    if (Test-Path $candidate) {
      $sdkmanagerFound = $true
      $sdkmanagerPath = Split-Path $candidate -Parent
      break
    }
  }
}

if (-not $sdkmanagerFound) {
  Add-Issue `
    "Android SDK command-line tools are missing (sdkmanager not found)." `
    "1) Download cmdline-tools from https://developer.android.com/studio#command-tools`n2) Extract into %ANDROID_SDK_ROOT%\cmdline-tools\latest`n3) setx PATH `"%PATH%;%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin`"`n4) sdkmanager --licenses"
}

$adbFound = $false
if (Has-Command "adb") {
  $adbFound = $true
}
elseif ($androidSdkPath) {
  $adbCandidate = Join-Path $androidSdkPath "platform-tools\adb.exe"
  if (Test-Path $adbCandidate) {
    $adbFound = $true
  }
}

if (-not $adbFound) {
  Add-Issue `
    "Android platform-tools are missing (adb not found)." `
    "sdkmanager `"platform-tools`"`nsetx PATH `"%PATH%;%ANDROID_SDK_ROOT%\platform-tools`""
}

if ($androidSdkPath) {
  $platformToolsPath = Join-Path $androidSdkPath "platform-tools"
  if ((Test-Path $platformToolsPath) -and (-not (Path-HasEntry $platformToolsPath))) {
    Add-Issue `
      "PATH is missing Android platform-tools directory." `
      "PowerShell: setx PATH `"%PATH%;%ANDROID_SDK_ROOT%\platform-tools`""
  }

  $cmdlineToolsLatestPath = Join-Path $androidSdkPath "cmdline-tools\latest\bin"
  $cmdlineToolsBinPath = Join-Path $androidSdkPath "cmdline-tools\bin"
  $hasCmdlinePath = (Path-HasEntry $cmdlineToolsLatestPath) -or (Path-HasEntry $cmdlineToolsBinPath)
  if ((Test-Path $cmdlineToolsLatestPath -or Test-Path $cmdlineToolsBinPath) -and (-not $hasCmdlinePath)) {
    Add-Issue `
      "PATH is missing Android command-line tools directory." `
      "PowerShell: setx PATH `"%PATH%;%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin`""
  }
}

$avdmanagerFound = $false
if (Has-Command "avdmanager") {
  $avdmanagerFound = $true
}
elseif ($androidSdkPath) {
  $avdCandidates = @(
    (Join-Path $androidSdkPath "cmdline-tools\latest\bin\avdmanager.bat"),
    (Join-Path $androidSdkPath "cmdline-tools\latest\bin\avdmanager"),
    (Join-Path $androidSdkPath "cmdline-tools\bin\avdmanager.bat"),
    (Join-Path $androidSdkPath "cmdline-tools\bin\avdmanager")
  )
  foreach ($candidate in $avdCandidates) {
    if (Test-Path $candidate) {
      $avdmanagerFound = $true
      break
    }
  }
}

if (-not $avdmanagerFound) {
  Add-Issue `
    "Android AVD manager is missing (avdmanager not found)." `
    "Ensure command-line tools are installed, then set path: setx PATH `"%PATH%;%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin`""
}

$connectedDevices = 0
if ($adbFound) {
  try {
    $adbOutput = & adb devices 2>$null
    $connectedDevices = @($adbOutput | Where-Object { $_ -match "\tdevice$" }).Count
  }
  catch {
    Add-Warning `
      "Could not query connected devices via adb." `
      "Run: adb start-server ; adb devices"
  }
}

$avdCount = 0
$emulatorFound = Has-Command "emulator"
if (-not $emulatorFound -and $androidSdkPath) {
  $emulatorCandidate = Join-Path $androidSdkPath "emulator\emulator.exe"
  if (Test-Path $emulatorCandidate) {
    $emulatorFound = $true
  }
}

if ($emulatorFound) {
  try {
    $avdList = & emulator -list-avds 2>$null
    $avdCount = @($avdList | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count
  }
  catch {
    Add-Warning `
      "Could not list emulators." `
      "Run: emulator -list-avds"
  }
}

if ($connectedDevices -eq 0 -and $avdCount -eq 0) {
  Add-Issue `
    "No physical device connected and no emulator configured." `
    "Physical device: enable Developer options + USB debugging, connect USB, then run adb devices.`nEmulator: sdkmanager `"emulator`" `"system-images;android-34;google_apis;x86_64`" ; avdmanager create avd -n pixel34 -k `"system-images;android-34;google_apis;x86_64`" ; emulator -avd pixel34"
}

if ($flutterFound) {
  try {
    $flutterDoctor = & flutter doctor -v 2>$null
    $hasAndroidToolchainIssue = @($flutterDoctor | Where-Object { $_ -match "Android toolchain.*✗" }).Count -gt 0
    if ($hasAndroidToolchainIssue) {
      Add-Warning `
        "Flutter doctor reports Android toolchain issues." `
        "Run: flutter doctor -v ; flutter doctor --android-licenses"
    }
  }
  catch {
    Add-Warning `
      "Could not run flutter doctor for deeper validation." `
      "Run: flutter doctor -v"
  }
}

if ($warnings.Count -gt 0) {
  Write-Host ""
  Write-Host "warnings:"
  foreach ($warning in $warnings) {
    Write-Host "- $($warning.Message)"
    if ($warning.Fix) {
      Write-Host "  fix command(s):"
      Write-Host "  $($warning.Fix -replace "`n", "`n  ")"
    }
  }
}

if ($issues.Count -gt 0) {
  Write-Host ""
  Write-Host "mobile setup check failed:"
  foreach ($issue in $issues) {
    Write-Host "- $($issue.Message)"
    if ($issue.Fix) {
      Write-Host "  fix command(s):"
      Write-Host "  $($issue.Fix -replace "`n", "`n  ")"
    }
  }
  exit 1
}

Write-Host "mobile environment checks passed."
