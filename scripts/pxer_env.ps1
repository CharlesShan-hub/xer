#===============================================================================
# pxer_env.ps1 - Python environment setup (uv-based)
# For xer project
#
# Features:
#   1. Check if uv is installed
#   2. Create uv virtualenv (Python 3.12) if needed
#   3. Install dependencies with uv sync
#
# Usage:
#   .\scripts\pxer_env.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

# Colors
function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) {
    $ScriptDir = $PSScriptRoot
}

# pxer project directory
$PxerDir = Join-Path (Join-Path $ScriptDir "..") "pxer" | Resolve-Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  xer - Python Environment Setup (uv)"
Write-Host "========================================"
Write-Host ""

#===============================================================================
# Check uv
#===============================================================================
Write-Info "Checking uv..."

if (Get-Command uv -ErrorAction SilentlyContinue) {
    $uvVersion = uv --version
    Write-Info "uv installed: $uvVersion"
} else {
    Write-Err "uv not found!"
    Write-Host ""
    Write-Host "Install uv:"
    Write-Host "  powershell:   iwr https://astral.sh/uv/install.ps1 | iex"
    Write-Host "  winget:       winget install -e --id=astral-sh.uv"
    Write-Host "  other:        https://github.com/astral-sh/uv#installation"
    exit 1
}

#===============================================================================
# Check Python 3.12
#===============================================================================
Write-Info "Checking Python 3.12..."

$pythonList = uv python list 2>&1 | Out-String
if ($pythonList -match "3\.12") {
    Write-Info "Python 3.12 available"
} else {
    Write-Warn "Python 3.12 not installed"
    Write-Host ""
    Write-Host "Install Python 3.12:"
    Write-Host "  uv python install 3.12"
    exit 1
}

#===============================================================================
# Check/create virtualenv
#===============================================================================
Write-Info "Checking virtualenv..."
$VenvDir = Join-Path $PxerDir ".venv"

if (Test-Path $VenvDir) {
    Write-Info "Virtualenv exists: $VenvDir"
} else {
    Write-Info "Creating virtualenv..."
    Push-Location $PxerDir
    try {
        uv venv $VenvDir --python 3.12
        Write-Info "Virtualenv created"
    } finally {
        Pop-Location
    }
}

#===============================================================================
# Install dependencies
#===============================================================================
Write-Info "Installing dependencies..."

Push-Location $PxerDir
try {
    uv sync
    Write-Info "Dependencies installed"
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Info "Python environment ready!"
Write-Host "========================================"
Write-Host ""
Write-Host "Project dir : $PxerDir"
Write-Host "Virtualenv  : $VenvDir"
Write-Host "Python path : $PythonBin"
Write-Host ""
Write-Host "Run test:"
Write-Host "  cd $PxerDir"
Write-Host "  .\.venv\Scripts\Activate.ps1"
Write-Host "  python test.py"
Write-Host ""
