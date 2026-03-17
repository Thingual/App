# Thingual Backend Server Startup - PowerShell
# Uses Hypercorn for Windows compatibility

param(
    [switch]$Debug = $false,
    [int]$Port = 8002
)

$ErrorActionPreference = "Stop"

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Thingual Backend API Server (Windows PowerShell)" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

# Check Python
Write-Host "Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Found $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "✗ Python not found. Please install Python 3.10+" -ForegroundColor Red
    exit 1
}

# Navigate to backend directory
Push-Location $PSScriptRoot

# Create virtual environment if needed
if (-not (Test-Path "venv")) {
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Yellow
& ".\venv\Scripts\Activate.ps1"

# Install dependencies
Write-Host "Installing/updating dependencies..." -ForegroundColor Yellow
pip install -q -r requirements.txt

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Dependencies installed" -ForegroundColor Green
Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Starting Thingual Backend with Hypercorn..." -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Swagger UI:  http://localhost:$Port/docs" -ForegroundColor Magenta
Write-Host "📊 ReDoc:       http://localhost:$Port/redoc" -ForegroundColor Magenta
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Set debug flag if specified
if ($Debug) {
    $env:DEBUG = "True"
}

# Start server
python start_hypercorn.py

Pop-Location
