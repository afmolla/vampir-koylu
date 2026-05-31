@echo off
REM Eski C:\apps\flutter\BASLAT-API.cmd yerine bunu kopyala:
REM   copy /Y "%~dp0MASAUSTU-BASLAT-YONLENDIR.cmd" "C:\apps\flutter\BASLAT-API.cmd"
REM veya masaustune: BASLAT-API.cmd

if exist "C:\apps\vampir-koylu\BASLAT-API.cmd" (
  call "C:\apps\vampir-koylu\BASLAT-API.cmd"
  exit /b %ERRORLEVEL%
)
if exist "C:\inetpub\wwwroot\oyun1\BASLAT-API.cmd" (
  call "C:\inetpub\wwwroot\oyun1\BASLAT-API.cmd"
  exit /b %ERRORLEVEL%
)
echo HATA: vampir-koylu reposu yok. Once: git clone https://github.com/afmolla/vampir-koylu.git C:\apps\vampir-koylu
pause
exit /b 1
