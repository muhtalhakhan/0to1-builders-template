param(
  [string]$TargetDir,
  [string]$RepoUrl,
  [ValidateSet("web", "mobile")]
  [string]$Scaffold = $(if ($env:SCAFFOLD) { $env:SCAFFOLD } else { "web" })
)

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/muhtalhakhan/0to1-builders-template.git"
$RAW_BASE_URL = "https://raw.githubusercontent.com/muhtalhakhan/0to1-builders-template/main"
$INSTALL_DIR = "$HOME\Desktop\0to1-builders"

if (-not $TargetDir) { $TargetDir = $INSTALL_DIR }
if (-not $RepoUrl) { $RepoUrl = $REPO_URL }

function Require-Command {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Missing required command: $Name"
  }
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   0to1-builders - setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "scaffold: $Scaffold"
Write-Host ""

Write-Host "[1/4] checking prerequisites..."
Require-Command git

if (Test-Path $TargetDir) {
  $base = $TargetDir
  $i = 1
  while (Test-Path $TargetDir) {
    $TargetDir = "${base}-${i}"
    $i++
  }
  Write-Host "note: '$base' already exists, using '$TargetDir' instead."
}

Write-Host "[2/4] cloning template..."
git clone $RepoUrl $TargetDir

Set-Location $TargetDir

if ($Scaffold -eq "web") {
  Require-Command node
  Require-Command npm
  Write-Host "[3/4] setting up web scaffold..."
  npm install

  Write-Host "[4/4] running setup verification..."
  npm run check
}
else {
  Set-Location "scaffolds/flutter-app"
  Write-Host "[3/4] setting up mobile scaffold..."
  powershell -ExecutionPolicy Bypass -File "..\..\scripts\check-mobile-prereqs.ps1"
  Write-Host "[4/4] installing flutter packages..."
  flutter pub get
}

Write-Host ""
Write-Host "setup complete. your project is ready in:" -ForegroundColor Green
Write-Host "open this folder in codex:"
Write-Host (Resolve-Path ".")
