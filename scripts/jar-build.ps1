#===============================================================================
# jar-build.ps1 - check binaries + copy to resources + Maven package
# For xer project
#
# Prerequisites:
#   - cxer/windows/origin.exe   (built by build-win.ps1)
#   - cxer/linux/origin.bin     (built by build-linux.ps1)
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info  { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Step  { param($msg) Write-Host "[STEP] $msg" -ForegroundColor Cyan }
function Write-Pass  { param($msg) Write-Host "[PASS] $msg" -ForegroundColor Green }
function Write-Fail  { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }
function Write-Warn  { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }
$XerRoot    = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$CxerWinDir = Join-Path $XerRoot "cxer\windows"
$CxerLinDir = Join-Path $XerRoot "cxer\linux"
$JxerResDir = Join-Path $XerRoot "jxer\jxer\src\main\resources"
$JxerModule = Join-Path $XerRoot "jxer\jxer"
$JxerJar    = Join-Path $JxerModule "target\jxer-1.0.0.jar"

# Check binaries
Write-Step "Checking native binaries..."
$winExe = Join-Path $CxerWinDir "origin.exe"
$linBin = Join-Path $CxerLinDir "origin.bin"
$hasWin = Test-Path $winExe
$hasLin = Test-Path $linBin

if (-not ($hasWin -or $hasLin)) {
    Write-Fail "Neither origin.exe nor origin.bin found!"
    Write-Host "Run build-win.ps1 and/or build-linux.ps1 first." -ForegroundColor Yellow
    exit 1
}

if ($hasWin) {
    Write-Pass "Found Windows binary:  $winExe"
} else {
    Write-Warn "origin.exe not found (Windows build was skipped)"
}

if ($hasLin) {
    Write-Pass "Found Linux binary:    $linBin"
} else {
    Write-Warn "origin.bin not found (Linux build was skipped)"
}

# Copy to resources
Write-Step "Copying binaries to resources..."
$winResDir = Join-Path $JxerResDir "native\win32"
$linResDir = Join-Path $JxerResDir "native\linux"
New-Item -ItemType Directory -Path $winResDir -Force | Out-Null
New-Item -ItemType Directory -Path $linResDir -Force | Out-Null

if ($hasWin) {
    Copy-Item $winExe -Destination $winResDir -Force
    Write-Pass "  native/win32/origin.exe"
}
if ($hasLin) {
    Copy-Item $linBin -Destination $linResDir -Force
    Write-Pass "  native/linux/origin.bin"
}

# Maven package
Write-Step "Maven package..."
Push-Location $JxerModule
try {
    & mvn clean install -q
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Maven package failed!"
        exit 1
    }
} finally {
    Pop-Location
}
Write-Pass "JAR: $JxerJar"
exit 0
