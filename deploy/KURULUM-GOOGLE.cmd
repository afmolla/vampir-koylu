@echo off
title Google giris kurulumu
cd /d "%~dp0"

if not exist "google-oauth.local.cmd" (
  copy /Y "google-oauth.local.cmd.example" "google-oauth.local.cmd"
  echo google-oauth.local.cmd olusturuldu.
)

echo.
echo Google Cloud Console Web Client ID yapistir:
echo   deploy\google-oauth.local.cmd
echo.
notepad "google-oauth.local.cmd"
echo.
echo Kaydettikten sonra API: ..\BASLAT-API.cmd
echo Test: http://85.95.251.204:3002/api/config/public  - googleSignInEnabled: true
pause
