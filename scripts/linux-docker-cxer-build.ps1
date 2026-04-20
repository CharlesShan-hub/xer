#===============================================================================
# linux-docker-cxer_build.ps1 - Build cxer (Nuitka Python -> Linux binary) via Docker
# For xer project - Linux build
#
# What it does:
#   Runs docker-compose cxer-build service to compile origin.py with Nuitka
#   Output: cxer/linux/origin.bin
#
# Usage:
#   .\scripts\linux-docker-cxer_build.ps1
#===============================================================================

$ErrorActionPreference = "Stop"

function Write-Info { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) {
    $ScriptDir = $PSScriptRoot
}

$XerDir    = Join-Path $ScriptDir ".." | Resolve-Path
$CxerDir   = Join-Path $XerDir "cxer\linux"
$OriginPy  = Join-Path (Join-Path $XerDir "pxer") "origin.py"
$DockerYml = Join-Path $XerDir "docker-compose.yml"

Write-Host "--- xer - Nuitka Build (Linux via Docker) ---" -ForegroundColor Cyan
Write-Host ""

#===============================================================================
# Pre-flight checks
#===============================================================================
Write-Info "Checking origin.py..."
if (-not (Test-Path $OriginPy)) {
    Write-Err "origin.py not found: $OriginPy"
    exit 1
}
Write-Info "  origin.py exists"

Write-Info "Checking docker-compose.yml..."
if (-not (Test-Path $DockerYml)) {
    Write-Err "docker-compose.yml not found: $DockerYml"
    exit 1
}
Write-Info "  docker-compose.yml exists"

# Ensure Linux output dir exists (host side, for docker volume mount)
$HostLinuxDir = Join-Path $XerDir "cxer\linux"
if (-not (Test-Path $HostLinuxDir)) {
    New-Item -ItemType Directory -Path $HostLinuxDir -Force | Out-Null
}

#===============================================================================
# Build via docker-compose
#===============================================================================
Write-Info "Running docker-compose cxer-build..."
Write-Host ""

Push-Location $XerDir
try {
    # Build and run in detached mode, then wait for it to finish
    docker compose up --build --detach cxer-build
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Nuitka build failed."
        exit 1
    }

    Write-Info "Build container running, waiting for completion..."
    docker wait xer-cxer-build
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Nuitka build failed inside container."
        exit 1
    }
} finally {
    Pop-Location
}

#===============================================================================
# Find and report output
#===============================================================================
Write-Info "Checking output..."
$LinuxBinary = Join-Path $CxerDir "origin.bin"

if (Test-Path $LinuxBinary) {
    $size = (Get-Item $LinuxBinary).Length / 1MB
    Write-Info "Binary found: $LinuxBinary ($([math]::Round($size, 1)) MB)"
} else {
    Write-Warn "Binary not found at cxer/linux/origin.bin"
    Write-Host ""
    Write-Host "Looking for Nuitka output..."
    Get-ChildItem $CxerDir -Filter "origin*" | ForEach-Object {
        Write-Host "  Found: $($_.FullName)"
    }
}

Write-Host ""
Write-Host "--- xer - Linux binary build complete! ---" -ForegroundColor Green
Write-Host ""
Write-Host "Output: $LinuxBinary"
Write-Host ""
exit 0
