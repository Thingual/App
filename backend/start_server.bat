@echo off
REM Thingual Backend Server Startup Script - Windows Batch
REM Uses Hypercorn instead of uvicorn for better Windows compatibility

cd /d "%~dp0"

if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

call venv\Scripts\activate.bat

echo Installing dependencies...
pip install -q -r requirements.txt

echo.
echo Starting Thingual Backend with Hypercorn...
echo.

python start_hypercorn.py

pause
