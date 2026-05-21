@echo off
title Vampir Koylu API
cd /d "%~dp0"

echo Port 3000 temizleniyor...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do taskkill /PID %%a /F 2>nul

echo.
echo === Vampir Koylu API (normal) ===
set PORT=3000
set NODE_ENV=production
set MIN_REQUIRED_VERSION=0.1.0
set LATEST_VERSION=0.1.4
set FORCE_UPDATE=true
set UPDATE_URL_ANDROID=https://github.com/afmolla/flutter/releases/download/v0.1.7/app-release.apk
set JWT_SECRET=vampir-koylu-production-change-me
set JWT_EXPIRES_IN=7d

echo MIN_REQUIRED_VERSION=%MIN_REQUIRED_VERSION%
echo Dinleniyor: http://0.0.0.0:3000
echo Pencereyi KAPATMA - API durur.
echo.
node src\index.js
pause
