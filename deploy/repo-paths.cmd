REM GitHub: https://github.com/afmolla/vampir-koylu

set GITHUB_REPO=afmolla/vampir-koylu
set GITHUB_CLONE_URL=https://github.com/afmolla/vampir-koylu.git

REM Bu makine (wwwroot / IIS)
set VPS_APP_DIR=C:\inetpub\wwwroot\oyun1

REM Uzak VPS (clone hedefi)
REM set VPS_APP_DIR=C:\apps\vampir-koylu

set PUBLIC_IP=85.95.251.204
set API_PORT=3002
set LATEST_VERSION=0.2.34
set APK_PUBLISH_VERSION=0.2.34
set MIN_REQUIRED_VERSION=0.2.6

REM Google OAuth (tek satir Client ID): deploy\google-oauth.local.cmd
if exist "%~dp0google-oauth.local.cmd" call "%~dp0google-oauth.local.cmd"
