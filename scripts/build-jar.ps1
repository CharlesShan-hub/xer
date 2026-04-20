#===============================================================================
# build-jar.ps1 - JAR build: env check + copy binaries + maven package + test
# For xer project
#
# Steps:
#   3.1: jar-env.ps1   - Java + Maven environment check
#   3.2: jar-build.ps1 - Copy binaries to resources + Maven package
#   3.3: jar-test.ps1  - Compile and run jxer-test
#
# Usage:
#   .\scripts\build-jar.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }

Write-Host ""
Write-Host "--- xer - JAR Build ---" -ForegroundColor Cyan

Write-Host "[3.1] jar-env.ps1..."
& "$ScriptDir\jar-env.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[3.2] jar-build.ps1..."
& "$ScriptDir\jar-build.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[3.3] jar-test.ps1..."
& "$ScriptDir\jar-test.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "--- JAR build done. Output: jxer/jxer/target/jxer-1.0.0.jar ---" -ForegroundColor Green
Write-Host ""

exit 0
