@echo off
REM === VPS veya sunucu PC'de YONETICI olarak calistir ===
REM Bu dosyayi sunucudaki server klasorune kopyala ve cift tikla.

cd /d "%~dp0"
if not exist "src\index.js" (
  echo HATA: Bu CMD server klasorunun icinde olmali!
  echo Ornek: C:\apps\vampir-koylu\server\SUNUCU-GUNCELLEME-ACIL.cmd
  pause
  exit /b 1
)

echo Eski node surecleri kapatiliyor (port 3000)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do taskkill /PID %%a /F 2>nul

echo.
echo === GUNCELLEME AYARI (0.2.4 acilir, 0.2.5 guncelleme sorar) ===
set PORT=3000
set NODE_ENV=production
set MIN_REQUIRED_VERSION=0.2.4
set LATEST_VERSION=0.2.5
set FORCE_UPDATE=true
set UPDATE_URL_ANDROID=https://github.com/afmolla/flutter/releases/download/v0.2.5/app-release.apk
set JWT_SECRET=vampir-koylu-production-change-me
set JWT_EXPIRES_IN=7d

echo MIN=%MIN_REQUIRED_VERSION%  LATEST=%LATEST_VERSION%
echo APK=%UPDATE_URL_ANDROID%
echo.
echo Test (baska PC tarayici):
echo http://85.95.251.204:3000/api/version?clientVersion=0.2.4^&platform=android
echo Beklenen: needsUpdate true, latestVersion 0.2.5
echo.
node src\index.js
