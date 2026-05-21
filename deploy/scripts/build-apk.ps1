# APK build — API adresini parametre ver
# Örnek (sunucu IP):
#   powershell -File deploy\scripts\build-apk.ps1 -ApiUrl "http://123.45.67.89:3000"
# Örnek (domain):
#   powershell -File deploy\scripts\build-apk.ps1 -ApiUrl "https://api.senindomain.com"
# Emülatör / aynı PC test:
#   powershell -File deploy\scripts\build-apk.ps1

param(
    [string]$ApiUrl = "http://10.0.2.2:3000"
)

$ErrorActionPreference = "Stop"
$FlutterBin = "C:\src\flutter\bin"
if (Test-Path $FlutterBin) {
    $env:Path = "$FlutterBin;" + $env:Path
}

$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Mobile = Join-Path $Root "mobile"
Set-Location $Mobile

Write-Host "API_BASE_URL = $ApiUrl" -ForegroundColor Cyan
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=$ApiUrl

$Apk = Join-Path $Mobile "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $Apk) {
    $Dest = Join-Path $Root "vampir-koylu-release.apk"
    Copy-Item $Apk $Dest -Force
    Write-Host ""
    Write-Host "APK hazir:" -ForegroundColor Green
    Write-Host "  $Apk"
    Write-Host "  $Dest"
} else {
    Write-Host "APK bulunamadi — build logunu kontrol et." -ForegroundColor Red
    exit 1
}
