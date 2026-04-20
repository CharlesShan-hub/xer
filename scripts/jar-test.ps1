#===============================================================================
# jar-test.ps1 - compile and run jxer-test
# For xer project
#
# Usage:
#   .\scripts\jar-test.ps1 [asnDir]    # default: ../asn
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info  { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Step  { param($msg) Write-Host "[STEP] $msg" -ForegroundColor Cyan }
function Write-Pass  { param($msg) Write-Host "[PASS] $msg" -ForegroundColor Green }
function Write-Fail  { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }
$XerRoot    = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$JxerModule = Join-Path $XerRoot "jxer\jxer"
$JxerTestDir = Join-Path $XerRoot "jxer\jxer-test"
$JxerJar    = Join-Path $JxerModule "target\jxer-1.0.0.jar"
$asnDir     = if ($args.Length -gt 0) { $args[0] } else { Join-Path $XerRoot "asn" }

Write-Step "Building jxer-test..."
Push-Location $JxerTestDir
try {
    & mvn clean compile -q
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "jxer-test build failed!"
        exit 1
    }
    Write-Pass "jxer-test compiled"
} finally {
    Pop-Location
}

Write-Step "Running Asn1ConverterTest with asnDir: $asnDir"
$cp = "$JxerTestDir\target\classes;$JxerJar"
& java -cp $cp com.xer.test.Asn1ConverterTest $asnDir
if ($LASTEXITCODE -eq 0) {
    Write-Pass "All tests passed!"
} else {
    Write-Fail "Tests failed!"
    exit 1
}

exit 0
