#===============================================================================
# jar-env.ps1 - Java/Maven environment check
# For xer project
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Pass { param($msg) Write-Host "[PASS] $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }

$all_pass = $true

# Java
$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if ($javaCmd) {
    $versionOutput = cmd /c "java -version 2>&1"
    Write-Pass "Java found: $($versionOutput[0])"
} else {
    Write-Fail "Java not found!"
    Write-Host "Install Java 8+ from: https://adoptium.net/" -ForegroundColor Yellow
    $all_pass = $false
}

# Maven
$mvnCmd = Get-Command mvn -ErrorAction SilentlyContinue
if ($mvnCmd) {
    $mvnVersion = & mvn -version 2>&1 | Select-Object -First 1
    Write-Pass "Maven found: $mvnVersion"
} else {
    Write-Fail "Maven not found!"
    Write-Host "Install Maven from: https://maven.apache.org/download.cgi" -ForegroundColor Yellow
    $all_pass = $false
}

if (-not $all_pass) {
    Write-Fail "Environment check failed."
    exit 1
}

Write-Pass "Environment check passed"
exit 0
