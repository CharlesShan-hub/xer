#===============================================================================
# build.ps1 - Build all: Windows exe + Linux bin + JAR
#===============================================================================
# Usage:
#   .\scripts\build.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[1] build-win.ps1" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
& "$ScriptDir\build-win.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[2] build-linux.ps1" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
& "$ScriptDir\build-linux.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[3] build-jar.ps1" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
& "$ScriptDir\build-jar.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[OK] All done."
