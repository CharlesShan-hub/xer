#===============================================================================
# windows-cxer_test.ps1 - Test xer.exe with test data
# For xer project - Windows build
#
# Usage:
#   .\scripts\windows-cxer_test.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Test { param($msg) Write-Host "  $msg" }

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) {
    $ScriptDir = $PSScriptRoot
}

# Paths
$XerExe = Join-Path (Join-Path $ScriptDir "..") "cxer\windows\origin.exe"
$AsnFile = Join-Path (Join-Path $ScriptDir "..") "asn\mms.asn"

# Test data
$BertToAperTest = @{
    Input    = "a01502016fa610a00ea10c1a04544553541a0456414c31"
    Expected = "006f3404544553540456414c31"
}

$AperToBerTest = @{
    Input    = "006f3404544553540456414c31"
    Expected = "a01502016fa610a00ea10c1a04544553541a0456414c31"
}

Write-Host "--- xer - Test BER <-> APER (exe) ---" -ForegroundColor Cyan
Write-Host ""

# Check exe
if (-not (Test-Path $XerExe)) {
    Write-Err "origin.exe not found: $XerExe"
    Write-Host ""
    Write-Host "Run windows-cxer_build.ps1 first."
    exit 1
}

# Check ASN
if (-not (Test-Path $AsnFile)) {
    Write-Err "ASN file not found: $AsnFile"
    exit 1
}

Write-Info "Exe   : $XerExe"
Write-Info "ASN   : $AsnFile"
Write-Host ""

# Test 1: BER -> APER
Write-Host "--- Test 1: BER -> APER ---" -ForegroundColor Yellow
Write-Test "Input (BER hex)   : $($BertToAperTest.Input)"
Write-Test "Expected (APER)   : $($BertToAperTest.Expected)"

$Output = & $XerExe --ber-to-aper $BertToAperTest.Input --asn $AsnFile 2>&1 | Select-Object -Last 1

Write-Test "Result (APER hex)  : $Output"

if ($Output -eq $BertToAperTest.Expected) {
    Write-Host "  [PASS]" -ForegroundColor Green
} else {
    Write-Host "  [FAIL]" -ForegroundColor Red
}

Write-Host ""

# Test 2: APER -> BER
Write-Host "--- Test 2: APER -> BER ---" -ForegroundColor Yellow
Write-Test "Input (APER hex)  : $($AperToBerTest.Input)"
Write-Test "Expected (BER)    : $($AperToBerTest.Expected)"

$Output = & $XerExe --aper-to-ber $AperToBerTest.Input --asn $AsnFile 2>&1 | Select-Object -Last 1

Write-Test "Result (BER hex)   : $Output"

if ($Output -eq $AperToBerTest.Expected) {
    Write-Host "  [PASS]" -ForegroundColor Green
} else {
    Write-Host "  [FAIL]" -ForegroundColor Red
}

Write-Host ""
Write-Host "--- xer - cxer test complete! ---" -ForegroundColor Green
exit 0
