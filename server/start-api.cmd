@echo off
title Vampir Koylu API - v0.2.7
cd /d "%~dp0"

echo Port 3000 temizleniyor...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do taskkill /PID %%a /F 2>nul

echo.
echo === Vampir Koylu API v0.2.7 ===
set PORT=3000
set NODE_ENV=production
set MIN_REQUIRED_VERSION=0.2.6
set LATEST_VERSION=0.2.7
set FORCE_UPDATE=true
set UPDATE_URL_ANDROID=https://github.com/afmolla/flutter/releases/download/v0.2.7/app-release.apk
set JWT_SECRET=vampir-koylu-production-change-me
set JWT_EXPIRES_IN=7d

echo MIN_REQUIRED_VERSION=%MIN_REQUIRED_VERSION%
echo LATEST_VERSION=%LATEST_VERSION%
echo APK: %UPDATE_URL_ANDROID%
echo Test: http://127.0.0.1:3000/api/version?clientVersion=0.2.6
echo Dinleniyor: http://0.0.0.0:3000
echo Pencereyi KAPATMA - API durur.
echo.
node src\index.js
pause
