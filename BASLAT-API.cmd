@echo off
setlocal EnableExtensions
REM ============================================================
REM  Vampir Koylu - API tek tik baslatma (GUNCEL: print-build + git pull)
REM  VPS repo:  C:\apps\vampir-koylu\BASLAT-API.cmd
REM  wwwroot:   C:\inetpub\wwwroot\oyun1\BASLAT-API.cmd
REM  Eski masaustu kopyasi CALISMAZ — bu dosyayi veya asagidaki yonlendirmeyi kullan.
REM ============================================================
title Vampir Koylu - BASLAT-API

set "REPO_ROOT=%~dp0"
if "%REPO_ROOT:~-1%"=="\" set "REPO_ROOT=%REPO_ROOT:~0,-1%"

echo.
echo ============================================================
echo   BASLAT-API  (launcher guncel: 2026-05-28)
echo   Repo: %REPO_ROOT%
echo ============================================================
echo.

if exist "%REPO_ROOT%\deploy\repo-paths.cmd" call "%REPO_ROOT%\deploy\repo-paths.cmd"

if not defined VPS_APP_DIR set "VPS_APP_DIR=%REPO_ROOT%"

echo Masaustu kisayolu eskiyse su dosyayi calistir:
echo   %VPS_APP_DIR%\BASLAT-API.cmd
echo.

if exist "%VPS_APP_DIR%\server\start-api.cmd" (
  call "%VPS_APP_DIR%\server\start-api.cmd"
  exit /b %ERRORLEVEL%
)

if exist "%REPO_ROOT%\server\start-api.cmd" (
  call "%REPO_ROOT%\server\start-api.cmd"
  exit /b %ERRORLEVEL%
)

echo HATA: server\start-api.cmd bulunamadi.
echo VPS: git clone https://github.com/afmolla/vampir-koylu.git C:\apps\vampir-koylu
echo       sonra C:\apps\vampir-koylu\BASLAT-API.cmd
pause
exit /b 1
