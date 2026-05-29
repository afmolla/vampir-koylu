@echo off
REM VPS'te YONETICI olarak calistir (85.95.251.204)
title Vampir Koylu - port 3002 kontrol

echo === 1) Node 3002 dinliyor mu? ===
netstat -ano | findstr ":3002 " | findstr LISTENING
if errorlevel 1 (
  echo HATA: 3002 dinlemiyor. Once BASLAT-API.cmd calistir.
) else (
  echo OK: 3002 LISTENING
)

echo.
echo === 2) Yerel health ===
curl -s http://127.0.0.1:3002/health
echo.

echo.
echo === 3) Windows Firewall 3002 ===
netsh advfirewall firewall delete rule name="Vampir Koylu API" >nul 2>&1
netsh advfirewall firewall add rule name="Vampir Koylu API" dir=in action=allow protocol=TCP localport=3002
echo.

echo === 4) Dis test (bu PC'den) ===
curl -s --max-time 8 http://85.95.251.204:3002/health
echo.
echo Telefonda da ac: http://85.95.251.204:3002/health
echo ok:true gormezsen: hosting panelinde TCP 3002 inbound ac (Contabo/Hetzner firewall)
pause
