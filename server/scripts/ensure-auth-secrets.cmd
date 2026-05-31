@echo off
setlocal EnableExtensions
cd /d "%~dp0.."

set "AUTH_FILE=auth-secrets.env"
set "DEPLOY_LOCAL=%~dp0..\..\deploy\google-oauth.local.cmd"

if exist "%DEPLOY_LOCAL%" call "%DEPLOY_LOCAL%"

if defined GOOGLE_CLIENT_ID (
  echo %GOOGLE_CLIENT_ID% | findstr /i /c:".apps.googleusercontent.com" >nul 2>&1
  if not errorlevel 1 goto :write_secrets
)

if exist "%AUTH_FILE%" (
  findstr /i /c:".apps.googleusercontent.com" "%AUTH_FILE%" >nul 2>&1
  if not errorlevel 1 (
    findstr /i /c:"xxxxxxxx" "%AUTH_FILE%" >nul 2>&1
    if errorlevel 1 exit /b 0
  )
)

exit /b 1

:write_secrets
(
  echo # Otomatik - BASLAT-API / ensure-auth-secrets.cmd
  echo GOOGLE_CLIENT_ID=%GOOGLE_CLIENT_ID%
) > "%AUTH_FILE%"
if defined GOOGLE_ANDROID_CLIENT_ID echo GOOGLE_ANDROID_CLIENT_ID=%GOOGLE_ANDROID_CLIENT_ID%>> "%AUTH_FILE%"
if defined FACEBOOK_APP_ID echo FACEBOOK_APP_ID=%FACEBOOK_APP_ID%>> "%AUTH_FILE%"
if defined FACEBOOK_APP_SECRET echo FACEBOOK_APP_SECRET=%FACEBOOK_APP_SECRET%>> "%AUTH_FILE%"
exit /b 0
