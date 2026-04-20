#===============================================================================
# build-linux.ps1 - Linux build via Docker: exe + test
# For xer project
#
# Steps:
#   2.1: linux-docker-pxer-env.ps1   - Check Docker
#   2.2: linux-docker-cxer-build.ps1 - Compile origin.py -> cxer/linux/origin.bin
#   2.3: linux-docker-cxer-test.ps1  - Smoke test the binary
#
# Usage:
#   .\scripts\build-linux.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }

Write-Host ""
Write-Host "--- xer - Linux Build (Docker) ---" -ForegroundColor Cyan

Write-Host "[2.1] linux-docker-pxer-env.ps1..."
& "$ScriptDir\linux-docker-pxer-env.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[2.2] linux-docker-cxer-build.ps1..."
& "$ScriptDir\linux-docker-cxer-build.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[2.3] linux-docker-cxer-test.ps1..."
& "$ScriptDir\linux-docker-cxer-test.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "--- Linux build done. Output: cxer/linux/origin.bin ---" -ForegroundColor Green
Write-Host ""

exit 0
