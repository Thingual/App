param(
    [switch]$RunInBackground = $false,
    [int]$Port = 8002
)

# Determine backend root directory
if ($MyInvocation.MyCommandPath) {
    $BackendRoot = Split-Path -Parent $MyInvocation.MyCommandPath
} else {
    $BackendRoot = "d:\thingual\thingual\backend"
}

$VenvPath = Join-Path (Split-Path -Parent $BackendRoot) ".venv"
$PythonExe = Join-Path (Join-Path $VenvPath "Scripts") "python.exe"
$StartScript = Join-Path $BackendRoot "start_hypercorn.py"

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $color = "White"
    if ($Level -eq "ERROR") { $color = "Red" }
    elseif ($Level -eq "WARN") { $color = "Yellow" }
    elseif ($Level -eq "SUCCESS") { $color = "Green" }
    Write-Host "[$Level] $Message" -ForegroundColor $color
}

function Test-Prerequisites {
    Write-Log "Checking Python..." "INFO"
    
    if (-not (Test-Path $PythonExe)) {
        Write-Log "Python not found at $PythonExe" "ERROR"
        throw "Python environment not configured"
    }
    
    $pythonVersion = & $PythonExe --version 2>&1
    Write-Log "Found: $pythonVersion" "SUCCESS"
}

function Start-Backend {
    param([bool]$Background)
    
    Write-Log "" "INFO"
    Write-Log "=============== Thingual Backend Server ===============" "INFO"
    Write-Log "Backend: $BackendRoot" "INFO"
    Write-Log "Python: $PythonExe" "INFO"
    Write-Log "Port: $Port" "INFO"
    
    if ($Background) {
        Write-Log "Mode: Background (detached)" "INFO"
    } else {
        Write-Log "Mode: Foreground (press Ctrl+C to stop)" "INFO"
    }
    Write-Log "======================================================" "INFO"
    Write-Log "" "INFO"
    
    $env:API_PORT = $Port
    $env:PYTHONUNBUFFERED = "1"
    $env:PYTHONIOENCODING = "utf-8"
    
    if ($Background) {
        $outLog = Join-Path $BackendRoot "server_output.log"
        $errLog = Join-Path $BackendRoot "server_error.log"
        
        Write-Log "Starting background process..." "INFO"
        
        $proc = Start-Process -FilePath $PythonExe `
            -ArgumentList $StartScript `
            -WorkingDirectory $BackendRoot `
            -NoNewWindow `
            -RedirectStandardOutput $outLog `
            -RedirectStandardError $errLog `
            -PassThru
        
        Write-Log "Process started: PID $($proc.Id)" "SUCCESS"
        Write-Log "Output log: $outLog" "INFO"
        Write-Log "Error log: $errLog" "INFO"
        
        Start-Sleep -Seconds 3
        
        if ($proc.HasExited) {
            Write-Log "Process exited immediately!" "ERROR"
            $errors = Get-Content $errLog -ErrorAction SilentlyContinue
            if ($errors) {
                Write-Log "Errors: $errors" "ERROR"
            }
            throw "Server failed to start"
        }
        
        Write-Log "Server is running!" "SUCCESS"
        Write-Log "Kill with: taskkill /PID $($proc.Id)" "INFO"
        
    } else {
        Write-Log "Starting server..." "INFO"
        & $PythonExe $StartScript
    }
}

try {
    Test-Prerequisites
    Start-Backend -Background:$RunInBackground
} catch {
    Write-Log "ERROR: $_" "ERROR"
    exit 1
}

exit 0
