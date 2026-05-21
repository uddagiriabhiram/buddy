@echo off
title X Buddy — First Time Setup
color 0B

echo.
echo  X Buddy — First Time Setup
echo  ===========================
echo.

:: Auto-detect current username and project path
set CURRENT_USER=%USERNAME%
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

echo  Detected username : %CURRENT_USER%
echo  Detected path     : %SCRIPT_DIR%
echo.

:: Fix START X BUDDY.bat with correct paths
echo  Fixing paths in START X BUDDY.bat...
powershell -NoProfile -Command ^
  "(Get-Content '%SCRIPT_DIR%\START X BUDDY.bat') ^
   -replace 'C:\\\\Users\\\\[^\\\\]+\\\\Desktop\\\\xbuddy\\\\X-buddy-main', '%SCRIPT_DIR%' ^
   -replace 'C:\\\\Users\\\\[^\\\\]+\\\\Desktop\\\\X buddy server', (Split-Path '%SCRIPT_DIR%') + '\X buddy server' ^
   -replace 'C:\\\\Users\\\\[^\\\\]+\\\\', 'C:\\Users\\%CURRENT_USER%\\' ^
   | Set-Content '%SCRIPT_DIR%\START X BUDDY.bat'"
echo  Done!
echo.

:: Check Node.js
echo  Checking Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
  echo  [MISSING] Node.js not found! Install from https://nodejs.org
) else (
  for /f %%v in ('node --version') do echo  [OK] Node.js %%v
)

:: Check Git
echo  Checking Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
  echo  [MISSING] Git not found! Install from https://git-scm.com
) else (
  for /f "tokens=1,2,3" %%a in ('git --version') do echo  [OK] Git %%c
)

:: Check credentials.json
echo  Checking credentials.json...
set AGENT_DIR=%SCRIPT_DIR%\..\X buddy server\startserver
if exist "%AGENT_DIR%\credentials.json" (
  echo  [OK] credentials.json found
) else (
  echo  [MISSING] credentials.json not found!
  echo           Place it in: %AGENT_DIR%\
  echo           Get it from: https://console.cloud.google.com/iam-admin/serviceaccounts
  echo           Project: flash-direction-496513-f6
)

:: Check cloudflared.exe
echo  Checking cloudflared.exe...
if exist "%AGENT_DIR%\cloudflared.exe" (
  echo  [OK] cloudflared.exe found
) else (
  echo  [MISSING] cloudflared.exe not found!
  echo           Place it in: %AGENT_DIR%\
  echo           Get it from: https://github.com/cloudflare/cloudflared/releases/latest
  echo           Download: cloudflared-windows-amd64.exe and rename to cloudflared.exe
)

:: Check qr-code.png
echo  Checking qr-code.png...
if exist "%SCRIPT_DIR%\public\qr-code.png" (
  echo  [OK] qr-code.png found
) else (
  echo  [MISSING] qr-code.png not found!
  echo           Place your UPI QR image at: %SCRIPT_DIR%\public\qr-code.png
)

:: Check node_modules frontend
echo  Checking frontend dependencies...
if exist "%SCRIPT_DIR%\node_modules" (
  echo  [OK] node_modules found
) else (
  echo  [INSTALLING] Running npm install for frontend...
  cd /d "%SCRIPT_DIR%"
  npm install
)

:: Check node_modules agent
echo  Checking print agent dependencies...
if exist "%AGENT_DIR%\node_modules" (
  echo  [OK] Print agent node_modules found
) else (
  echo  [INSTALLING] Running npm install for print agent...
  cd /d "%AGENT_DIR%"
  npm install
)

echo.
echo  ===========================
echo  Setup complete!
echo  Now run: START X BUDDY.bat
echo  ===========================
echo.
pause
