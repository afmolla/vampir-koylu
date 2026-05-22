# VPS (85.95.251.204) uzerinde YONETICI PowerShell ile calistir.
# Ornek: cd C:\apps\vampir-koylu\deploy
#        powershell -ExecutionPolicy Bypass -File .\VPS-API-GUNCELLE.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ServerDir = Join-Path $RepoRoot "server"

Write-Host "=== Vampir Koylu API guncelleme (0.2.7) ===" -ForegroundColor Cyan
Write-Host "Server klasoru: $ServerDir"

if (-not (Test-Path (Join-Path $ServerDir "src\index.js"))) {
    Write-Host "HATA: server klasoru bulunamadi. Once git pull veya ZIP cikartin." -ForegroundColor Red
    exit 1
}

Write-Host "`nPort 3000 dinleyen surecler kapatiliyor..."
Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique |
    ForEach-Object {
        Write-Host "  PID $_ sonlandiriliyor"
        Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
    }
Start-Sleep -Seconds 2

Set-Location $ServerDir

if (-not (Test-Path "node_modules")) {
    Write-Host "`nnpm install..."
    npm install
}

$env:PORT = "3000"
$env:NODE_ENV = "production"
$env:MIN_REQUIRED_VERSION = "0.2.6"
$env:LATEST_VERSION = "0.2.7"
$env:FORCE_UPDATE = "true"
$env:UPDATE_URL_ANDROID = "https://github.com/afmolla/flutter/releases/download/v0.2.7/app-release.apk"
$env:JWT_SECRET = "vampir-koylu-production-change-me"
$env:JWT_EXPIRES_IN = "7d"

Write-Host "`nAyarlar:"
Write-Host "  MIN=$env:MIN_REQUIRED_VERSION  LATEST=$env:LATEST_VERSION"
Write-Host "  APK=$env:UPDATE_URL_ANDROID"

$logDir = Join-Path $ServerDir "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir "api-stdout.log"

Write-Host "`nAPI arka planda baslatiliyor (log: $logFile)..."
$nodeExe = (Get-Command node -ErrorAction Stop).Source
Start-Process -FilePath $nodeExe -ArgumentList "src\index.js" -WorkingDirectory $ServerDir `
    -WindowStyle Hidden -RedirectStandardOutput $logFile -RedirectStandardError $logFile

Start-Sleep -Seconds 4

Write-Host "`nKontrol /health ..."
try {
    $health = Invoke-RestMethod -Uri "http://127.0.0.1:3000/health" -TimeoutSec 10
    $health | ConvertTo-Json -Depth 5
    if ($health.serverBuild -ne "0.2.7") {
        Write-Host "UYARI: serverBuild hala eski — yanlis klasorden mi calisiyor?" -ForegroundColor Yellow
    }
    if ($health.version.latestVersion -ne "0.2.7") {
        Write-Host "UYARI: latestVersion 0.2.7 degil!" -ForegroundColor Yellow
    }
} catch {
    Write-Host "HATA: API yanit vermiyor. Log: $logFile" -ForegroundColor Red
    Get-Content $logFile -Tail 30 -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "`nKontrol /api/version (client 0.2.4) ..."
$ver = Invoke-RestMethod -Uri "http://127.0.0.1:3000/api/version?clientVersion=0.2.4&platform=android"
$ver | ConvertTo-Json
if ($ver.needsUpdate -ne $true) {
    Write-Host "UYARI: needsUpdate true olmali!" -ForegroundColor Yellow
}

Write-Host "`nTAMAM. Dis test:" -ForegroundColor Green
Write-Host "http://85.95.251.204:3000/health"
Write-Host "http://85.95.251.204:3000/api/version?clientVersion=0.2.4&platform=android"
