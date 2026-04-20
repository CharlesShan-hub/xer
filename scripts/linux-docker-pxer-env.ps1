#===============================================================================
# linux-docker-pxer_env.ps1 - Check Docker and docker-compose availability
# For xer project - Linux build via Docker
#
# Usage:
#   .\scripts\linux-docker-pxer_env.ps1
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

$XerDir = Join-Path $ScriptDir ".." | Resolve-Path

Write-Host "--- xer - Linux Build Environment Check ---" -ForegroundColor Cyan
Write-Host ""

#===============================================================================
# Check Docker
#===============================================================================
Write-Info "Checking Docker..."
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Info "Docker found: $(docker --version)"
} else {
    Write-Err "Docker not found!"
    Write-Host ""
    Write-Host "Install Docker Desktop:"
    Write-Host "  https://docs.docker.com/desktop/install/windows-install/"
    exit 1
}

# Check if Docker daemon is running
Write-Info "Checking Docker daemon..."
$null = docker ps 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Err "Docker daemon is not running!"
    Write-Host ""
    Write-Host "Please start Docker Desktop and wait for it to be ready."
    exit 1
}
Write-Info "Docker daemon is running"

#===============================================================================
# Check docker-compose
#===============================================================================
Write-Info "Checking docker-compose..."

$HasComposeV2 = Get-Command docker -ErrorAction SilentlyContinue
$ComposeCheck = docker compose version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Info "docker-compose (v2) found: $ComposeCheck"
} else {
    Write-Err "docker-compose v2 not available!"
    Write-Host ""
    Write-Host "Docker Desktop on Windows includes compose v2 by default."
    Write-Host "If 'docker compose' fails, update Docker Desktop to the latest version."
    exit 1
}

#===============================================================================
# Check if Dockerfile exists
#===============================================================================
Write-Info "Checking Dockerfile..."
$Dockerfile = Join-Path (Join-Path $XerDir "docker") "Dockerfile"
if (-not (Test-Path $Dockerfile)) {
    Write-Err "Dockerfile not found: $Dockerfile"
    exit 1
}
Write-Info "Dockerfile found"

Write-Host ""
Write-Host "--- xer - Linux build environment ready! ---" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Run .\scripts\linux-docker-cxer_build.ps1"
Write-Host ""
exit 0
