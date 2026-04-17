#===============================================================================
# cxer_build.ps1 - Build Python to standalone exe with Nuitka
#
# Features:
#   Uses uv virtualenv Python + MSVC compiler
#   Compiles origin.py to a standalone .exe
#
# Usage:
#   .\scripts\cxer_build.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

# Colors
function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) {
    $ScriptDir = $PSScriptRoot
}

# Paths
$PxerDir = Join-Path (Join-Path $ScriptDir "..") "pxer" | Resolve-Path
$CxerDir = Join-Path (Join-Path $ScriptDir "..") "cxer"

# Virtualenv Python
$VenvPython = Join-Path (Join-Path (Join-Path $PxerDir ".venv") "Scripts") "python.exe"

# Check virtualenv
if (-not (Test-Path $VenvPython)) {
    Write-Err "Virtualenv not found. Run pxer_env.ps1 first."
    Write-Host ""
    Write-Host "  .\scripts\pxer_env.ps1"
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  xer - Nuitka Build"
Write-Host "========================================"
Write-Host ""

# Check origin.py
Write-Info "Checking files..."
$OriginPy = Join-Path $PxerDir "origin.py"

if (-not (Test-Path $OriginPy)) {
    Write-Err "origin.py not found: $OriginPy"
    exit 1
}
Write-Info "  origin.py exists"

Write-Host ""
Write-Info "Running Nuitka..."
Write-Host ""

# Paths
$AsnDir = Join-Path (Join-Path $ScriptDir "..") "asn"

# Nuitka command
& $VenvPython -m nuitka `
    --standalone `
    --onefile `
    --msvc=latest `
    --include-package=pycrate_asn1rt `
    --include-data-dir=$AsnDir=asn `
    --output-dir=$CxerDir `
    $OriginPy

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Info "Build complete!"
Write-Host "========================================"
Write-Host ""
Write-Host "Output dir: $CxerDir"
Write-Host ""
