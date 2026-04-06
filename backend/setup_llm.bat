@echo off
REM Quick start script for LLM inference setup
REM Run this from the project root directory

echo ========================================
echo Thingual LLM Inference Setup
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Please install Python 3.10+
    exit /b 1
)

echo [1/4] Installing backend dependencies...
cd backend
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    exit /b 1
)
echo [OK] Dependencies installed

echo.
echo [2/4] Verifying llama-cpp-python installation...
python -c "import llama_cpp; print(f'llama-cpp-python version: {llama_cpp.__version__}')"
if errorlevel 1 (
    echo ERROR: llama-cpp-python not properly installed
    exit /b 1
)
echo [OK] llama-cpp-python ready

echo.
echo [3/4] Starting backend server...
echo       Server will start at http://localhost:8000
echo       Press Ctrl+C to stop
echo.
python start_server.bat

echo.
echo [4/4] In another terminal, run:
echo       flutter run
echo.
echo ========================================
echo Setup Complete!
echo ========================================
