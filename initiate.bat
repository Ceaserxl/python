@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0"

echo ===========================================
echo   Portable Python Initializer (Windows)
echo ===========================================
echo.

:: ------------------------------------------
:: CONFIG
:: ------------------------------------------
set "ARCHIVE=cpython-3.13.7windows.zip"
set "OUTDIR=%CD%\win-x64"
set "PYDIR=%OUTDIR%\python"
set "PYPATH=%PYDIR%\python.exe"
set "VENV_DIR=%CD%\wvenv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"

:: ------------------------------------------
:: Validate archive
:: ------------------------------------------
if not exist "%ARCHIVE%" (
    echo [!] ERROR: %ARCHIVE% not found.
    pause
    exit /b 1
)

:: ------------------------------------------
:: Reset win-x64 directory
:: ------------------------------------------
if exist "%OUTDIR%" (
    echo [*] Removing old win-x64...
    rmdir /s /q "%OUTDIR%"
)

echo [*] Creating win-x64...
mkdir "%OUTDIR%" >nul 2>&1

:: ------------------------------------------
:: Extract archive
:: ------------------------------------------
echo [*] Extracting portable Python...
powershell -NoLogo -NoProfile -Command ^
 "$ProgressPreference='SilentlyContinue'; Expand-Archive '%ARCHIVE%' '%OUTDIR%' -Force"

echo [*] Extraction complete.
echo.

:: ------------------------------------------
:: Verify known python.exe path
:: ------------------------------------------
if not exist "%PYPATH%" (
    echo [!] ERROR: python.exe missing at expected location:
    echo     %PYPATH%
    echo.
    echo Your ZIP must extract so that:
    echo     win-x64\python\python.exe
    echo.
    pause
    exit /b 1
)

echo [OK] Found python.exe:
echo     %PYPATH%
echo.

:: ------------------------------------------
:: Create wvenv
:: ------------------------------------------
if exist "%VENV_DIR%" (
    echo [*] Removing old wvenv...
    rmdir /s /q "%VENV_DIR%"
)

echo [*] Creating virtual environment...
call "%PYPATH%" -m venv "%VENV_DIR%"

if not exist "%VENV_PY%" (
    echo [!] ERROR: Failed to create virtual environment.
    pause
    exit /b 1
)

echo [OK] Virtual environment created:
echo     %VENV_DIR%
echo.

echo [*] Initialization complete.
echo.
exit /b 0
