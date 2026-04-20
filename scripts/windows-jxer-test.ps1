#===============================================================================
# windows-jxer_test.ps1 - Build and run jxer-test project
# For xer project - Windows build
#
# jxer-test is a separate project that depends on jxer library.
#
# Usage:
#   .\scripts\windows-jxer_test.ps1 [asnDir]
#
# Args:
#   asnDir - Path to ASN.1 runtime directory (default: ../asn)
#===============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$JxerDir = Join-Path $RootDir "jxer\jxer"
$JxerTestDir = Join-Path $RootDir "jxer\jxer-test"
$JxerJar = Join-Path $JxerDir "target\jxer-1.0.0.jar"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Pass { param($msg) Write-Host "[PASS] $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "--- xer - Build & Run Asn1Converter Test ---" -ForegroundColor Cyan
Write-Host ""

# Check Maven
if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    Write-Fail "Maven not found!"
    Write-Host "Run windows-jxer_env.ps1 first."
    exit 1
}

# Check jxer JAR exists
if (-not (Test-Path $JxerJar)) {
    Write-Fail "jxer JAR not found: $JxerJar"
    Write-Host "Run jxer_build.ps1 first."
    exit 1
}

# Get asnDir from args
$asnDir = if ($args.Length -gt 0) { $args[0] } else { Join-Path $RootDir "asn" }

Write-Info "Using asnDir: $asnDir"

# Build jxer-test
Write-Info "Building jxer-test..."
Push-Location $JxerTestDir
try {
    & mvn clean compile -q
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Build failed!"
        exit 1
    }
} finally {
    Pop-Location
}
Write-Pass "Build successful"

# Run test
Write-Info "Running Asn1ConverterTest..."
Push-Location $JxerTestDir
try {
    $cp = "$JxerTestDir\target\classes;$JxerJar"
    & java -cp $cp com.xer.test.Asn1ConverterTest $asnDir
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "--- xer - All tests passed! ---" -ForegroundColor Green
    } else {
        Write-Fail "Tests failed!"
        exit 1
    }
} finally {
    Pop-Location
}
exit $LASTEXITCODE
