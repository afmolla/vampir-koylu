@echo off
REM VPS: masaustu kisayolu veya C:\apps\flutter\BASLAT-API.cmd
REM Tum is: server\start-api.cmd (cd + git pull + port + node)
if exist "%~dp0deploy\repo-paths.cmd" call "%~dp0deploy\repo-paths.cmd"
if exist "%VPS_APP_DIR%\server\start-api.cmd" (
  call "%VPS_APP_DIR%\server\start-api.cmd"
) else (
  call "%~dp0server\start-api.cmd"
)
