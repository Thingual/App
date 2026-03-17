$ErrorActionPreference = 'Stop'

$port = 8002

function Get-ListenerPids([int]$p) {
  if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
    return Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty OwningProcess -Unique
  }

  return netstat -ano | Select-String ":${p}\s+.*LISTENING\s+(\d+)" | ForEach-Object {
    [int]$_.Matches[0].Groups[1].Value
  } | Select-Object -Unique
}

$maxAttempts = 10
for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
  $processIds = @(Get-ListenerPids $port)
  if (-not $processIds -or $processIds.Count -eq 0) {
    Write-Host "No process is listening on port $port."
    exit 0
  }

  Write-Host "Stopping listeners on port $port (attempt $attempt/$maxAttempts) (PIDs: $($processIds -join ', '))"
  foreach ($processId in $processIds) {
    try { Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue } catch {}
    try { taskkill /F /PID $processId 2>$null | Out-Null } catch {}
  }

  Start-Sleep -Milliseconds 500
}

$remaining = @(Get-ListenerPids $port)
if ($remaining -and $remaining.Count -gt 0) {
  $hint = "Port $port is still in LISTEN state after $maxAttempts attempts. Remaining PIDs: $($remaining -join ', ').`n" +
          "If those PIDs are not visible/killable (common without elevation), re-run this script in an elevated PowerShell (Run as Administrator)."
  throw $hint
}

Write-Host "Port $port is now free."