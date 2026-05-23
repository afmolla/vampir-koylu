@echo off
REM ============================================================
REM  Vampir Koylu - API tek tik baslatma
REM  VPS: C:\apps\flutter\BASLAT-API.cmd  (masaustu kisayolu)
REM  Yerel: C:\inetpub\wwwroot\oyun1\BASLAT-API.cmd
REM ============================================================
title Vampir Koylu - BASLAT-API

if exist "%~dp0deploy\repo-paths.cmd" call "%~dp0deploy\repo-paths.cmd"

if exist "%VPS_APP_DIR%\server\start-api.cmd" (
  call "%VPS_APP_DIR%\server\start-api.cmd"
) else if exist "%~dp0server\start-api.cmd" (
  call "%~dp0server\start-api.cmd"
) else (
  echo HATA: server\start-api.cmd bulunamadi.
  echo Aranan: %~dp0server\start-api.cmd
  echo VPS icin deploy\repo-paths.cmd icinde VPS_APP_DIR kontrol et.
  pause
  exit /b 1
)
