#===============================================================================
# windows-jxer_env.ps1 - Check Java and Maven environment
# For xer project - Windows build
#
# Usage:
#   .\scripts\windows-jxer_env.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Pass { param($msg) Write-Host "[PASS] $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }
function Write-Warn { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }

Write-Host "--- xer - Java/Maven Environment Check ---" -ForegroundColor Cyan
Write-Host ""

$all_pass = $true

#===============================================================================
# Check Java
#===============================================================================
Write-Info "Checking Java..."

if (Get-Command java -ErrorAction SilentlyContinue) {
    $versionOutput = cmd /c "java -version 2>&1"
    Write-Pass "Java found: $($versionOutput[0])"
} else {
    Write-Fail "Java not found!"
    Write-Host "Install Java 8+ from: https://adoptium.net/"
    $all_pass = $false
}

#===============================================================================
# Check Maven
#===============================================================================
Write-Info "Checking Maven..."

if (Get-Command mvn -ErrorAction SilentlyContinue) {
    $mvnVersion = & mvn -version 2>&1 | Select-Object -First 1
    Write-Pass "Maven found: $mvnVersion"
} else {
    Write-Fail "Maven not found!"
    Write-Host "Install Maven from: https://maven.apache.org/download.cgi"
    $all_pass = $false
}

Write-Host ""
Write-Host "--- xer - Java/Maven environment check done ---" -ForegroundColor Cyan
Write-Host ""

if ($all_pass) {
    Write-Pass "All checks passed!"
    exit 0
} else {
    Write-Fail "Some checks failed."
    exit 1
}

