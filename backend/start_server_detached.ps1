$ErrorActionPreference = 'Stop'

$workingDir = 'D:\thingual\thingual\backend'

# Prefer a concrete Python 3.12 executable (Windows Store installs can include multiple shims)
$pythonCandidates = @(
  'C:\Users\karth\AppData\Local\Microsoft\WindowsApps\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\python.exe',
  'C:\Users\karth\AppData\Local\Microsoft\WindowsApps\python3.12.exe'
)

$python = $pythonCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not (Test-Path $python)) {
  throw "Python 3.12 not found. Checked: $($pythonCandidates -join ', ')"
}

# If something is already listening on 8002, stop it.
# Prefer Get-NetTCPConnection when available (more reliable than parsing netstat).
function Get-ListenerPids([int]$p) {
  if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
    return Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty OwningProcess -Unique
  }

  return netstat -ano | Select-String ":${p}\s+.*LISTENING\s+(\d+)" | ForEach-Object {
    [int]$_.Matches[0].Groups[1].Value
  } | Select-Object -Unique
}

$processIds = @(Get-ListenerPids 8002)
foreach ($processId in $processIds) {
  try { Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue } catch {}
  try { taskkill /F /PID $processId 2>$null | Out-Null } catch {}
}

Start-Sleep -Milliseconds 500
$still = @(Get-ListenerPids 8002)
if ($still -and $still.Count -gt 0) {
  throw "Port 8002 is still in use (PIDs: $($still -join ', ')). Run backend/stop_server.ps1 in an elevated PowerShell (Run as Administrator) to free the port."
}

$argList = @(
  '-m', 'hypercorn',
  'app.main:app',
  '--bind', '0.0.0.0:8002',
  '--workers', '1',
  '--log-level', 'info'
)

$env:PYTHONIOENCODING = 'utf-8'

$logDir = Join-Path $workingDir 'logs'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

$stdoutLog = Join-Path $logDir 'server_out.log'
$stderrLog = Join-Path $logDir 'server_err.log'

$proc = Start-Process -FilePath $python -WorkingDirectory $workingDir -ArgumentList $argList -RedirectStandardOutput $stdoutLog -RedirectStandardError $stderrLog -PassThru
Write-Host 'Backend starting on http://0.0.0.0:8002 (detached via Hypercorn)'
Write-Host "Logs: $stdoutLog / $stderrLog"

# Verify the port is owned by exactly one listener.
$deadline = (Get-Date).AddSeconds(10)
do {
  Start-Sleep -Milliseconds 250
  if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
    $listenerPids = Get-NetTCPConnection -LocalPort 8002 -State Listen -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty OwningProcess -Unique
  } else {
    $listenerPids = netstat -ano | Select-String ':8002\s+.*LISTENING\s+(\d+)' | ForEach-Object {
      [int]$_.Matches[0].Groups[1].Value
    } | Select-Object -Unique
  }
} while ((-not $listenerPids -or $listenerPids.Count -eq 0) -and (Get-Date) -lt $deadline)

if (-not $listenerPids -or $listenerPids.Count -eq 0) {
  try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch {}
  throw "Backend failed to bind to port 8002 within 10 seconds. Check logs: $stderrLog"
}

if ($listenerPids.Count -gt 1) {
  foreach ($processId in $listenerPids) {
    try { Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue } catch {}
  }
  try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch {}
  throw "Multiple processes are listening on port 8002 (PIDs: $($listenerPids -join ', ')). Killed them to avoid stale backends. Re-run start script."
}
