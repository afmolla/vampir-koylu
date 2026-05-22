@echo off
setlocal EnableExtensions
title VPS Git duzelt
cd /d "%~dp0.."

if exist "deploy\repo-paths.cmd" call "deploy\repo-paths.cmd"
if not defined VPS_APP_DIR set VPS_APP_DIR=%CD%

echo.
echo ============================================================
echo   Git duzelt: %VPS_APP_DIR%
echo ============================================================
echo.

if not exist "%VPS_APP_DIR%\.git" (
  echo HATA: .git yok. Once clone:
  echo   git clone https://github.com/afmolla/flutter.git %VPS_APP_DIR%
  pause
  exit /b 1
)

cd /d "%VPS_APP_DIR%"

echo [1] Durum...
git status
echo.

echo [2] fetch origin...
git fetch origin
if errorlevel 1 (
  echo HATA: fetch basarisiz. Internet veya yetki kontrol et.
  pause
  exit /b 1
)

echo [3] Yerel degisiklikleri sil, main ile esitle...
git reset --hard origin/main
git clean -fd -e server/data -e server/.env
echo.

echo [4] Tag temizligi (uzak)...
git fetch origin --prune --prune-tags 2>nul
echo.

echo [5] Son durum:
git status
git log -1 --oneline
echo.
echo TAMAM. Simdi: BASLAT-API.cmd
echo.
pause
