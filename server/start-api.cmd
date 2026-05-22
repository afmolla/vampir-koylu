@echo off
setlocal EnableExtensions
title Vampir Koylu API
cd /d "%~dp0"

REM --- Ortak yollar (GitHub repo: afmolla/flutter, VPS klasor: C:\apps\flutter) ---
if exist "%~dp0..\deploy\repo-paths.cmd" call "%~dp0..\deploy\repo-paths.cmd"

if not defined PUBLIC_IP set PUBLIC_IP=85.95.251.204
if not defined API_PORT set API_PORT=3000
if not defined LATEST_VERSION set LATEST_VERSION=0.2.7
if not defined MIN_REQUIRED_VERSION set MIN_REQUIRED_VERSION=0.2.6
if not defined GITHUB_REPO set GITHUB_REPO=afmolla/flutter

echo.
echo ============================================================
echo   Vampir Koylu API - TEK BASLATMA
echo   GitHub repo: %GITHUB_REPO%
echo   Bu klasor:   %CD%
echo ============================================================
echo.

REM --- 1) Port temizle (eski node) ---
echo [1/4] Port %API_PORT% temizleniyor...
for /L %%i in (1,1,3) do (
  for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%API_PORT% " ^| findstr LISTENING') do (
    echo       PID %%a sonlandiriliyor...
    taskkill /PID %%a /F >nul 2>&1
  )
  timeout /t 1 /nobreak >nul
)

REM --- 2) npm ---
echo [2/4] Bagimliliklar...
if not exist "node_modules\better-sqlite3" (
  echo       npm install calisiyor...
  call npm install
  if errorlevel 1 (
    echo HATA: npm install basarisiz.
    pause
    exit /b 1
  )
) else (
  echo       node_modules OK
)

REM --- 3) Ortam degiskenleri (guncel surum - .env'den once node'a gider) ---
echo [3/4] Surum ayarlari: MIN=%MIN_REQUIRED_VERSION%  LATEST=%LATEST_VERSION%
set PORT=%API_PORT%
set NODE_ENV=production
set MIN_REQUIRED_VERSION=%MIN_REQUIRED_VERSION%
set LATEST_VERSION=%LATEST_VERSION%
set FORCE_UPDATE=true
set UPDATE_URL_ANDROID=https://github.com/afmolla/flutter/releases/download/v%LATEST_VERSION%/app-release.apk
set JWT_SECRET=vampir-koylu-production-change-me
set JWT_EXPIRES_IN=7d

REM .env dosyasini da senkron tut (istege bagli okuma)
(
  echo PORT=%API_PORT%
  echo NODE_ENV=production
  echo MIN_REQUIRED_VERSION=%MIN_REQUIRED_VERSION%
  echo LATEST_VERSION=%LATEST_VERSION%
  echo FORCE_UPDATE=true
  echo UPDATE_URL_ANDROID=%UPDATE_URL_ANDROID%
  echo JWT_SECRET=%JWT_SECRET%
  echo JWT_EXPIRES_IN=7d
) > .env

REM --- 4) Node baslat ---
echo [4/4] API baslatiliyor...
echo.
echo   Yerel test:  http://127.0.0.1:%API_PORT%/health
echo   Dis test:    http://%PUBLIC_IP%:%API_PORT%/health
echo   Surum test:  http://%PUBLIC_IP%:%API_PORT%/api/version?clientVersion=0.2.4^&platform=android
echo.
echo   Beklenen health: serverBuild "%LATEST_VERSION%", latestVersion "%LATEST_VERSION%"
echo   Beklenen version: needsUpdate true (client 0.2.4 icin)
echo.
echo   ONEMLI: Bu pencereyi KAPATMA - API durur.
echo   Tarayici acilmiyorsa: deploy\FIREWALL-PORT-3000.cmd (Yonetici)
echo ============================================================
echo.

where node >nul 2>&1
if errorlevel 1 (
  echo HATA: node.exe bulunamadi. Node.js LTS kur.
  pause
  exit /b 1
)

node src\index.js
echo.
echo API durdu. Cikis kodu: %ERRORLEVEL%
pause
endlocal
