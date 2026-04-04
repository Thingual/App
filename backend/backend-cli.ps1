<#
.SYNOPSIS
    Quick commands for backend server management
.EXAMPLES
    .\backend-cli.ps1 start              # Start in foreground
    .\backend-cli.ps1 start-bg           # Start in background
    .\backend-cli.ps1 stop               # Stop background process
    .\backend-cli.ps1 status             # Check if running
    .\backend-cli.ps1 logs               # View recent logs
    .\backend-cli.ps1 health             # Test health endpoint
#>

param([string]$Command = "help")

$BackendRoot = Split-Path -Parent $MyInvocation.MyCommandPath
$VenvPath = Join-Path (Split-Path -Parent $BackendRoot) ".venv"
$PythonExe = Join-Path $VenvPath "Scripts" "python.exe"
$Port = 8002

function Show-Help {
    Write-Host @"
Thingual Backend CLI

Usage: .\backend-cli.ps1 [command]

Commands:
  start              Start server in foreground (blocking, shows all logs)
  start-bg           Start server in background (detached process)
  stop               Stop the background server process
  status             Check if server is running
  health             Test the /health endpoint
  logs               View server output log
  errors             View server error log
  init               Run full initialization script
  help               Show this help message

Examples:
  .\backend-cli.ps1 start              # Run in foreground, Ctrl+C to stop
  .\backend-cli.ps1 start-bg           # Run detached
  .\backend-cli.ps1 status             # Check if running
  .\backend-cli.ps1 health             # Verify server health
  .\backend-cli.ps1 logs               # Tail output log

"@
}

function Start-ForegroundServer {
    Write-Host "Starting backend server in foreground..." -ForegroundColor Green
    & "$BackendRoot\Initialize-BackendServer.ps1"
}

function Start-BackgroundServer {
    Write-Host "Starting backend server in background..." -ForegroundColor Green
    & "$BackendRoot\Initialize-BackendServer.ps1" -RunInBackground
}

function Stop-Server {
    $proc = Get-Process python -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -like "*start_hypercorn.py*"
    }
    
    if ($proc) {
        Write-Host "Stopping server process (PID: $($proc.Id))..." -ForegroundColor Yellow
        Stop-Process -Id $proc.Id -Force
        Write-Host "Server stopped." -ForegroundColor Green
    } else {
        Write-Host "No running backend server found." -ForegroundColor Yellow
    }
}

function Get-ServerStatus {
    $proc = Get-Process python -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -like "*start_hypercorn.py*"
    }
    
    if ($proc) {
        Write-Host "✓ Backend server is RUNNING" -ForegroundColor Green
        Write-Host "  PID: $($proc.Id)"
        Write-Host "  Memory: $([math]::Round($proc.WorkingSet / 1MB, 2)) MB"
        Write-Host "  Started: $($proc.StartTime)"
    } else {
        Write-Host "✗ Backend server is NOT RUNNING" -ForegroundColor Red
    }
}

function Test-ServerHealth {
    Write-Host "Testing server health at http://localhost:$Port/health..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port/health" `
            -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ Server is healthy!" -ForegroundColor Green
            Write-Host "Response: $($response.Content)" -ForegroundColor Green
            Write-Host ""
            Write-Host "API Documentation:" -ForegroundColor Cyan
            Write-Host "  OpenAPI: http://localhost:$Port/docs" -ForegroundColor Gray
            Write-Host "  ReDoc: http://localhost:$Port/redoc" -ForegroundColor Gray
        }
    } catch {
        Write-Host "✗ Health check failed: $_" -ForegroundColor Red
        Write-Host "Hint: Server may not be running. Try: .\backend-cli.ps1 start-bg" -ForegroundColor Yellow
    }
}

function Show-Logs {
    $logFile = Join-Path $BackendRoot "server_output.log"
    if (Test-Path $logFile) {
        Write-Host "=== Backend Server Output ===" -ForegroundColor Cyan
        Get-Content $logFile -Tail 50 | Write-Host
    } else {
        Write-Host "Log file not found: $logFile" -ForegroundColor Yellow
    }
}

function Show-Errors {
    $errorFile = Join-Path $BackendRoot "server_error.log"
    if (Test-Path $errorFile) {
        Write-Host "=== Backend Server Errors ===" -ForegroundColor Red
        Get-Content $errorFile -Tail 50 | Write-Host
    } else {
        Write-Host "Error log not found: $errorFile" -ForegroundColor Yellow
    }
}

# Main dispatcher
switch ($Command.ToLower()) {
    "start" { Start-ForegroundServer }
    "start-bg" { Start-BackgroundServer }
    "stop" { Stop-Server }
    "status" { Get-ServerStatus }
    "health" { Test-ServerHealth }
    "logs" { Show-Logs }
    "errors" { Show-Errors }
    "init" { & "$BackendRoot\Initialize-BackendServer.ps1" }
    "help" { Show-Help }
    "" { Show-Help }
    default { 
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Write-Host "Run: .\backend-cli.ps1 help" -ForegroundColor Yellow
    }
}
