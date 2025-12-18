@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0"

REM ------------------------------------------
REM CONFIG
REM ------------------------------------------
set "ARCHIVE=cpython-3.13.7windows.zip"
set "OUTDIR=%CD%\win-x64"
set "PYDIR=%OUTDIR%\python"
set "PYPATH=%PYDIR%\python.exe"
set "VENV_DIR=%OUTDIR%\wvenv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"

REM ------------------------------------------
REM FLAG HANDLING (-x = wipe)
REM ------------------------------------------
set "WIPE=0"
if /I "%~1"=="-x" (
    set "WIPE=1"
)

if "%WIPE%"=="1" (
    echo [*] Wipe mode enabled: resetting win-x64...
    if exist "%OUTDIR%" rmdir /s /q "%OUTDIR%"
)

REM ------------------------------------------
REM VALIDATE ARCHIVE
REM ------------------------------------------
if not exist "%ARCHIVE%" (
    echo [!] ERROR: Missing archive: %ARCHIVE%
    exit /b 1
)

REM ------------------------------------------
REM EXTRACT PYTHON (only if missing)
REM ------------------------------------------
if not exist "%PYPATH%" (
    echo [*] Extracting portable Python...
    mkdir "%OUTDIR%" >nul 2>&1
    powershell -NoLogo -NoProfile -Command ^
        "$ProgressPreference='SilentlyContinue'; Expand-Archive '%ARCHIVE%' '%OUTDIR%' -Force"
    echo [*] Extraction complete.
)

REM ------------------------------------------
REM VERIFY python.exe
REM ------------------------------------------
if not exist "%PYPATH%" (
    echo [!] ERROR: python.exe not found at:
    echo     %PYPATH%
    exit /b 1
)

echo [OK] Found python.exe:
echo     %PYPATH%

REM ------------------------------------------
REM CREATE VENV (only if missing)
REM ------------------------------------------
if not exist "%VENV_PY%" (
    echo [*] Creating virtual environment...
    call "%PYPATH%" -m venv "%VENV_DIR%"
)

if not exist "%VENV_PY%" (
    echo [!] ERROR: Failed to create venv:
    echo     %VENV_DIR%
    exit /b 1
)

echo [OK] Virtual environment ready.
echo [*] Initialization complete.
exit /b 0
