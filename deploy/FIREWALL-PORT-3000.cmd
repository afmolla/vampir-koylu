@echo off
REM YONETICI olarak calistir - disaridan 3000 portu acilir
if exist "%~dp0repo-paths.cmd" call "%~dp0repo-paths.cmd"
if not defined API_PORT set API_PORT=3000

echo Windows Firewall: TCP %API_PORT% gelen izin...
netsh advfirewall firewall delete rule name="Vampir Koylu API" >nul 2>&1
netsh advfirewall firewall add rule name="Vampir Koylu API" dir=in action=allow protocol=TCP localport=%API_PORT%
if errorlevel 1 (
  echo HATA: Kural eklenemedi. CMD'yi Yonetici olarak ac.
) else (
  echo Tamam. Test: http://85.95.251.204:%API_PORT%/health
)
pause
