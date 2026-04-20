#===============================================================================
# linux-docker-cxer_test.ps1 - Test the Linux binary inside Docker
# For xer project - Linux build verification
#
# What it does:
#   Starts a shell container with xer/ mounted, then runs the Linux binary
#
# Usage:
#   .\scripts\linux-docker-cxer_test.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) {
    $ScriptDir = $PSScriptRoot
}

$XerDir   = Join-Path $ScriptDir ".." | Resolve-Path
$CxerDir  = Join-Path $XerDir "cxer\linux"
$AsnDir   = Join-Path $XerDir "asn"
$Binary   = Join-Path $CxerDir "origin.bin"

Write-Host "--- xer - Linux Binary Test (via Docker) ---" -ForegroundColor Cyan
Write-Host ""

#===============================================================================
# Pre-flight
#===============================================================================
Write-Info "Checking Linux binary..."
if (-not (Test-Path $Binary)) {
    Write-Err "Linux binary not found: $Binary"
    Write-Host ""
    Write-Host "Run this first:"
    Write-Host "  .\scripts\linux-docker-cxer_build.ps1"
    exit 1
}
Write-Info "  binary exists"

Write-Info "Checking asn/ directory..."
if (-not (Test-Path $AsnDir)) {
    Write-Err "asn/ directory not found: $AsnDir"
    exit 1
}
Write-Info "  asn/ directory exists"

#===============================================================================
# Quick smoke test inside Docker
#===============================================================================
Write-Info "Running smoke test inside Docker..."
Write-Host ""

$TestScript = @'
set -e
cd /app

echo "[TEST] Checking binary..."
./cxer/linux/origin.bin --help 2>&1 | head -10

echo ""
echo "[TEST] BER decode test (InitiateRequestPDU)..."
echo '302400000001020104000001030400000001' | xxd -r -p | ./cxer/linux/origin.bin ber-decode -a asn 2>&1 | head -20

echo ""
echo "[TEST] All tests passed!"
'@

docker run --rm `
    -v "${XerDir}:/app" `
    -w /app `
    python:3.12-slim `
    bash -c $TestScript

if ($LASTEXITCODE -ne 0) {
    Write-Err "Test failed."
    exit 1
}

Write-Host ""
Write-Host "--- xer - Linux binary test complete! ---" -ForegroundColor Green
exit 0
