#===============================================================================
# jxer_build.ps1 - Build jxer Maven project
#
# Copies origin.exe to resources, then builds JAR.
#
# Usage:
#   .\scripts\jxer_build.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$CxerDir = Join-Path $RootDir "cxer"
$JxerDir = Join-Path $RootDir "jxer\jxer"
$ExeSrc = Join-Path $CxerDir "origin.exe"
$ResDir = Join-Path $JxerDir "src\main\resources"
$ExeDst = Join-Path $ResDir "origin.exe"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Pass { param($msg) Write-Host "[PASS] $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  xer - Build jxer JAR"
Write-Host "========================================"
Write-Host ""

# Check Maven
if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    Write-Fail "Maven not found!"
    Write-Host "Run jxer_env.ps1 first."
    exit 1
}

# Check exe exists
if (-not (Test-Path $ExeSrc)) {
    Write-Fail "origin.exe not found: $ExeSrc"
    exit 1
}

# Copy exe to resources (will be packaged into JAR)
Write-Info "Copying origin.exe to resources..."
if (-not (Test-Path $ResDir)) {
    New-Item -ItemType Directory -Path $ResDir -Force | Out-Null
}
Copy-Item $ExeSrc -Destination $ExeDst -Force
Write-Pass "Copied origin.exe"

# Build jxer
Write-Info "Building jxer..."
Push-Location $JxerDir
try {
    & mvn clean install -q
    if ($LASTEXITCODE -eq 0) {
        Write-Pass "Build + Install successful!"
        Write-Host ""
        Write-Host "JAR: jxer\jxer\target\jxer-1.0.0.jar"
        Write-Host "Installed to local Maven repository"
    } else {
        Write-Fail "Build failed!"
        exit 1
    }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Pass "Done!"
Write-Host "========================================"
