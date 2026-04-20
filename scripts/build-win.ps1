#===============================================================================
# build-win.ps1 - Windows build: Python env + C env + exe + test
# For xer project
#
# Steps:
#   1.1: windows-pxer-env.ps1    - uv Python environment
#   1.2: windows-pxer-test.ps1  - Python smoke test
#   1.3: windows-cxer-env.ps1    - MSVC compiler check
#   1.4: windows-cxer-build.ps1 - Compile origin.py -> cxer/windows/origin.exe
#   1.5: windows-cxer-test.ps1  - Smoke test the exe
#
# Usage:
#   .\scripts\build-win.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PSScriptRoot }

Write-Host ""
Write-Host "--- xer - Windows Build ---" -ForegroundColor Cyan

Write-Host "[1.1] windows-pxer-env.ps1..."
& "$ScriptDir\windows-pxer-env.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[1.2] windows-pxer-test.ps1..."
& "$ScriptDir\windows-pxer-test.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[1.3] windows-cxer-env.ps1..."
& "$ScriptDir\windows-cxer-env.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[1.4] windows-cxer-build.ps1..."
& "$ScriptDir\windows-cxer-build.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "[1.5] windows-cxer-test.ps1..."
& "$ScriptDir\windows-cxer-test.ps1"
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "--- Windows build done. Output: cxer/windows/origin.exe ---" -ForegroundColor Green
Write-Host ""

exit 0
