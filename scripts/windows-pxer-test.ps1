#===============================================================================
# windows-pxer_test.ps1 - Run Python test with uv virtualenv
# For xer project - Windows build
#
# Usage:
#   .\scripts\windows-pxer_test.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) {
    $ScriptDir = $PSScriptRoot
}

# Paths
$PxerDir = Join-Path (Join-Path $ScriptDir "..") "pxer" | Resolve-Path
$AsnDir = Join-Path (Join-Path $ScriptDir "..") "asn"
$AsnFile = Join-Path $AsnDir "mms.asn"
$VenvPython = Join-Path (Join-Path (Join-Path $PxerDir ".venv") "Scripts") "python.exe"

# Check virtualenv
if (-not (Test-Path $VenvPython)) {
    Write-Err "Virtualenv not found. Run windows-pxer_env.ps1 first."
    Write-Host ""
    Write-Host "  .\scripts\windows-pxer_env.ps1"
    exit 1
}

# Check ASN file
if (-not (Test-Path $AsnFile)) {
    Write-Err "ASN file not found: $AsnFile"
    exit 1
}

Write-Host "--- xer - Python Test ---" -ForegroundColor Cyan
Write-Host ""

Write-Info "Running test.py with ASN file: $AsnFile"
Write-Host ""

# Run test.py with ASN file argument
Push-Location $PxerDir
try {
    & $VenvPython test.py $AsnFile
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "--- xer - Python test complete! ---" -ForegroundColor Green
exit 0
