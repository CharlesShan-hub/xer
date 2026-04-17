#===============================================================================
# cxer_env.ps1 - Check C build environment (MSVC)
#
# Checks:
#   - Visual Studio Build Tools installed
#   - MSVC compiler available
#
# Usage:
#   .\scripts\cxer_env.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Pass { param($msg) Write-Host "[PASS] $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "[FAIL] $msg" -ForegroundColor Red }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  xer - C Build Environment Check"
Write-Host "========================================"
Write-Host ""

$all_pass = $true

#===============================================================================
# Check VS Build Tools installation path
#===============================================================================
Write-Info "Checking Visual Studio Build Tools..."

$vsBasePaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\18\Community",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools"
)

$vsPath = $null
foreach ($path in $vsBasePaths) {
    if (Test-Path $path) {
        $vsPath = $path
        break
    }
}

if ($vsPath) {
    Write-Pass "Visual Studio found: $vsPath"
} else {
    Write-Fail "Visual Studio not found!"
    Write-Host ""
    Write-Host "Install from: https://visualstudio.microsoft.com/downloads/"
    Write-Host "  -> Community or Professional or Enterprise"
    Write-Host "  -> Check 'Desktop development with C++'"
    $all_pass = $false
}

#===============================================================================
# Check MSVC compiler
#===============================================================================
Write-Info "Checking MSVC compiler..."

# Try to find cl.exe via VS Developer Command Prompt
$clPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe"
)

$clFound = $false
foreach ($pattern in $clPaths) {
    $cl = Get-ChildItem $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cl) {
        Write-Pass "MSVC cl.exe found: $($cl.FullName)"
        Write-Info "  Version: "
        & $cl.FullName /? | Select-Object -First 1
        $clFound = $true
        break
    }
}

if (-not $clFound) {
    Write-Fail "MSVC cl.exe not found!"
    Write-Host ""
    Write-Host "Make sure VS Build Tools is installed with C++ workload."
    Write-Host "Then run this script from 'Developer Command Prompt for VS 2022'"
    $all_pass = $false
}

#===============================================================================
# Summary
#===============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($all_pass) {
    Write-Pass "All checks passed! C build environment is ready."
} else {
    Write-Err "Some checks failed. Please fix the issues above."
    exit 1
}

Write-Host "========================================"
