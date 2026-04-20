#===============================================================================
# windows-cxer_build.ps1 - Build Python to standalone exe with Nuitka
# For xer project - Windows build
#
# Usage:
#   .\scripts\windows-cxer_build.ps1
#
# Prerequisites:
#   - windows-pxer-env.ps1   (uv virtualenv)
#   - windows-cxer-env.ps1    (MSVC compiler)
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }

$PxerDir = Join-Path (Join-Path $ScriptDir "..") "pxer" | Resolve-Path
$CxerDir = Join-Path (Join-Path $ScriptDir "..") "cxer\windows"
$VenvPython = Join-Path (Join-Path $PxerDir ".venv") "Scripts\python.exe"

if (-not (Test-Path $CxerDir)) {
    New-Item -ItemType Directory -Path $CxerDir -Force | Out-Null
}

# Check virtualenv
if (-not (Test-Path $VenvPython)) {
    Write-Err "Virtualenv not found. Run windows-pxer_env.ps1 first."
    Write-Host "  .\scripts\windows-pxer_env.ps1"
    exit 1
}
Write-Info "[PASS] Virtualenv found"

# Check origin.py
$OriginPy = Join-Path $PxerDir "origin.py"
if (-not (Test-Path $OriginPy)) {
    Write-Err "origin.py not found: $OriginPy"
    exit 1
}
Write-Info "[PASS] origin.py found"

# Run Nuitka
$AsnDir = Join-Path (Join-Path $ScriptDir "..") "asn"
& $VenvPython -m nuitka `
    --standalone `
    --onefile `
    --msvc=latest `
    --include-package=pycrate_asn1rt `
    --include-data-dir=$AsnDir=asn `
    --output-dir=$CxerDir `
    $OriginPy

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "--- xer - Nuitka build done. Output: $CxerDir ---" -ForegroundColor Green
    Write-Host ""
    exit 0
} else {
    Write-Err "Nuitka build failed."
    exit 1
}
