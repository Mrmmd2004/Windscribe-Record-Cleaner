@echo off
chcp 65001 >nul
setlocal

echo.
echo  ================================================
echo   Close Windscribe completely before continuing.
echo   (Right-click the tray icon and choose Exit)
echo  ================================================
echo.
echo  Press any key once Windscribe is closed...
pause >nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Windscribe-Record-Cleaner.ps1" %*
set "RC=%ERRORLEVEL%"

echo.
pause
exit /b %RC%
