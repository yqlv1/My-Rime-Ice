@echo off
setlocal
chcp 65001 >nul

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\relink-rime.ps1" -Force
set "result=%ERRORLEVEL%"

echo.
if "%result%"=="0" (
    echo Rime hard links are ready. Please redeploy Rime if files changed.
) else (
    echo Failed to repair Rime hard links. See the messages above.
)
pause
exit /b %result%
