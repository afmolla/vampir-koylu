0.2.@echo off
title Vampir Koylu API - GUNCELLEME TESTI
cd /d "%~dp0"

echo Port 3000 temizleniyor...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do taskkill /PID %%a /F 2>nul

echo.
echo === GUNCELLEME TESTI: eski APK engellenecek ===
set PORT=3000
set NODE_ENV=production
set MIN_REQUIRED_VERSION=0.2.0
set LATEST_VERSION=0.1.8
set FORCE_UPDATE=true
set UPDATE_URL_ANDROID=https://github.com/afmolla/flutter/releases/download/v0.1.8/app-release.apk
set JWT_SECRET=vampir-koylu-production-change-me
set JWT_EXPIRES_IN=7d

echo MIN_REQUIRED_VERSION=%MIN_REQUIRED_VERSION%  (0.1.x APK giremez)
echo Test: curl "http://127.0.0.1:3000/api/version?clientVersion=0.1.0"
echo.
node src\index.js
pause
