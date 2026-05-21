@echo off
title X Buddy — Master Startup
color 0D

echo.
echo  X Buddy Master Startup
echo  ======================
echo.

:: ── STEP 1: Start Cloudflare Tunnel ──────────────────────────────────────
echo [1/5] Starting Cloudflare Tunnel...
if exist "%TEMP%\xbuddy_tunnel.log" del "%TEMP%\xbuddy_tunnel.log"

cd /d "C:\Users\USER\Desktop\X buddy server\startserver"
start "Cloudflare Tunnel" /MIN cmd /c "cloudflared.exe tunnel --url http://localhost:3001 > "%TEMP%\xbuddy_tunnel.log" 2>&1"

echo      Waiting for tunnel URL (up to 30 seconds)...
set TUNNEL_URL=
set /a COUNT=0

:WAIT_LOOP
timeout /t 2 /nobreak >nul
set /a COUNT+=1
if %COUNT% GTR 15 goto TUNNEL_FAILED

for /f "delims=" %%u in ('powershell -NoProfile -Command "if (Test-Path $env:TEMP\xbuddy_tunnel.log) { $c = Get-Content $env:TEMP\xbuddy_tunnel.log -Raw -ErrorAction SilentlyContinue; if ($c -match 'https://[a-z0-9\-]+\.trycloudflare\.com') { $matches[0] } }"') do set TUNNEL_URL=%%u

if "%TUNNEL_URL%"=="" goto WAIT_LOOP
echo      Tunnel URL: %TUNNEL_URL%
echo.
goto TUNNEL_OK

:TUNNEL_FAILED
echo      Could not auto-detect tunnel URL.
set /p TUNNEL_URL=      Paste your tunnel URL here: 
echo.

:TUNNEL_OK

:: ── STEP 2: Update api.js ────────────────────────────────────────────────
echo [2/5] Updating api.js...
powershell -NoProfile -Command "(Get-Content 'C:\Users\USER\Desktop\xbuddy\X-buddy-main\src\utils\api.js') -replace \"const LOCAL_AGENT = '.*'\", \"const LOCAL_AGENT = '%TUNNEL_URL%'\" | Set-Content 'C:\Users\USER\Desktop\xbuddy\X-buddy-main\src\utils\api.js'"
echo      api.js updated: %TUNNEL_URL%
echo.

:: ── STEP 3: Skip git ─────────────────────────────────────────────────────
echo [3/5] Skipping GitHub push (git not installed)...
echo.

:: ── STEP 4: Start Print Agent ────────────────────────────────────────────
echo [4/5] Starting Print Agent...
start "X Buddy Print Agent" cmd /k "set PATH=C:\Program Files\nodejs;%PATH% && cd /d "C:\Users\USER\Desktop\X buddy server\startserver" && node index.js"
timeout /t 3 /nobreak >nul
echo      Print Agent started!
echo.

:: ── STEP 5: Start Website ────────────────────────────────────────────────
echo [5/5] Starting Website...
start "X Buddy Website" cmd /k "set PATH=C:\Program Files\nodejs;%PATH% && cd /d "C:\Users\USER\Desktop\xbuddy\X-buddy-main" && npm run dev"
timeout /t 6 /nobreak >nul
start "" "http://localhost:5173"
echo      Website started!
echo.

echo  ==========================================
echo  Everything is running!
echo  Website:    http://localhost:5173
echo  Tunnel URL: %TUNNEL_URL%
echo  ==========================================
echo.
pause
