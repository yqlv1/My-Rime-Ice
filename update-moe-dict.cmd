@echo off
setlocal
chcp 65001 >nul

if "%~1"=="" (
    echo Drag the downloaded moe.dict.yaml file onto this CMD file.
    pause
    exit /b 2
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\update-moe-dict.ps1" "%~1"
set "result=%ERRORLEVEL%"

echo.
if "%result%"=="0" (
    echo Dictionary updated. Please redeploy Rime.
) else (
    echo Dictionary update failed. The existing dictionary was not intentionally removed.
)
pause
exit /b %result%
