@echo off
setlocal EnableExtensions
title Vampir Koylu API

REM --- Ortak yollar (GitHub: afmolla/vampir-koylu, VPS: C:\apps\vampir-koylu) ---
if exist "%~dp0..\deploy\repo-paths.cmd" call "%~dp0..\deploy\repo-paths.cmd"

if not defined VPS_APP_DIR set VPS_APP_DIR=%~dp0..
if not defined PUBLIC_IP set PUBLIC_IP=85.95.251.204
if not defined API_PORT set API_PORT=3002
if not defined LATEST_VERSION set LATEST_VERSION=0.2.16
if not defined MIN_REQUIRED_VERSION set MIN_REQUIRED_VERSION=0.2.6
if not defined GITHUB_REPO set GITHUB_REPO=afmolla/vampir-koylu

REM VPS klasoru varsa oraya gec (tek cmd: cd + git pull + API)
if exist "%VPS_APP_DIR%\.git" (
  cd /d "%VPS_APP_DIR%"
) else (
  cd /d "%~dp0.."
  set VPS_APP_DIR=%CD%
)

echo.
echo ============================================================
echo   Vampir Koylu API - TEK BASLATMA
echo   GitHub repo: %GITHUB_REPO%
echo   Repo klasoru: %CD%
echo ============================================================
echo.

REM --- 0) GitHub'dan son kod ---
if not "%SKIP_GIT_PULL%"=="1" (
  echo [0/5] Git senkron...
  git fetch origin main 2>nul
  if errorlevel 1 (
    echo       UYARI: git fetch basarisiz - mevcut kodla devam.
  ) else (
    git rev-parse HEAD >nul 2>&1
    if errorlevel 1 (
      echo       UYARI: gecersiz repo.
    ) else (
      git merge-base --is-ancestor HEAD origin/main >nul 2>&1
      if errorlevel 1 (
        echo       Dal uyusmuyor - origin/main ile hizalaniyor...
        git reset --hard origin/main
        if errorlevel 1 (
          echo       HATA: reset basarisiz. Calistir: deploy\VPS-GIT-DUZELT.cmd
        ) else (
          echo       git reset --hard origin/main OK
        )
      ) else (
        git pull origin main
        if errorlevel 1 (
          echo       pull basarisiz - reset deneniyor...
          git reset --hard origin/main
          if errorlevel 1 (
            echo       HATA: deploy\VPS-GIT-DUZELT.cmd calistir
          ) else (
            echo       git pull/reset OK
          )
        ) else (
          echo       git pull OK
        )
      )
    )
  )
) else (
  echo [0/5] git atlandi (SKIP_GIT_PULL=1)
)
echo.

cd /d "%VPS_APP_DIR%\server"
if not exist "src\index.js" (
  echo HATA: server klasoru bulunamadi: %CD%
  pause
  exit /b 1
)

REM --- 1) Port temizle (eski node) ---
echo [1/5] Port %API_PORT% temizleniyor...
for /L %%i in (1,1,3) do (
  for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%API_PORT% " ^| findstr LISTENING') do (
    echo       PID %%a sonlandiriliyor...
    taskkill /PID %%a /F >nul 2>&1
  )
  timeout /t 1 /nobreak >nul
)

REM --- 2) npm ---
echo [2/5] Bagimliliklar...
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

REM --- 3) Ortam degiskenleri ---
echo [3/5] Surum ayarlari: MIN=%MIN_REQUIRED_VERSION%  LATEST=%LATEST_VERSION%
set PORT=%API_PORT%
set NODE_ENV=production
set MIN_REQUIRED_VERSION=%MIN_REQUIRED_VERSION%
set LATEST_VERSION=%LATEST_VERSION%
set FORCE_UPDATE=true
set APK_PUBLISH_VERSION=0.2.16
set APK_RELEASE_REPO=afmolla/vampir-koylu
set UPDATE_URL_ANDROID=https://github.com/%APK_RELEASE_REPO%/releases/download/v%APK_PUBLISH_VERSION%/app-release.apk
set JWT_SECRET=vampir-koylu-production-change-me
set JWT_EXPIRES_IN=7d
set ADMIN_API_KEY=vampir-admin-change-me

(
  echo PORT=%API_PORT%
  echo NODE_ENV=production
  echo MIN_REQUIRED_VERSION=%MIN_REQUIRED_VERSION%
  echo LATEST_VERSION=%LATEST_VERSION%
  echo APK_PUBLISH_VERSION=%APK_PUBLISH_VERSION%
  echo APK_RELEASE_REPO=%APK_RELEASE_REPO%
  echo FORCE_UPDATE=true
  echo UPDATE_URL_ANDROID=%UPDATE_URL_ANDROID%
  echo JWT_SECRET=%JWT_SECRET%
  echo JWT_EXPIRES_IN=7d
  echo ADMIN_API_KEY=%ADMIN_API_KEY%
) > .env

REM --- 4) Node baslat ---
echo [4/5] API baslatiliyor...
echo.
echo   Yerel test:  http://127.0.0.1:%API_PORT%/health
echo   Dis test:    http://%PUBLIC_IP%:%API_PORT%/health
echo   Surum test:  http://%PUBLIC_IP%:%API_PORT%/api/version?clientVersion=0.2.4^&platform=android
echo.
echo   Beklenen health: serverBuild "%LATEST_VERSION%", latestVersion "%LATEST_VERSION%"
echo.
echo   ONEMLI: Bu pencereyi KAPATMA - API durur.
echo   Tarayici acilmiyorsa: deploy\FIREWALL-PORT-3000.cmd (port %API_PORT%, Yonetici)
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
