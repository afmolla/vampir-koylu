# API baslat (watch yok — hata net gorunur)
# powershell -ExecutionPolicy Bypass -File C:\apps\vampir-koylu\deploy\scripts\windows-start-server.ps1

$ErrorActionPreference = "Stop"
$Root = if ($PSScriptRoot) {
    Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
} else { "C:\apps\flutter" }
$Server = Join-Path $Root "server"

if (-not (Test-Path (Join-Path $Server "package.json"))) {
    Write-Host "HATA: server klasoru yok: $Server" -ForegroundColor Red
    exit 1
}

$ApiPort = 3002
if (Test-Path (Join-Path $Server ".env")) {
    Get-Content (Join-Path $Server ".env") | ForEach-Object {
        if ($_ -match '^\s*PORT\s*=\s*(\d+)') { $ApiPort = [int]$Matches[1] }
    }
}
Write-Host ">> Port $ApiPort temizleniyor..." -ForegroundColor Cyan
Get-NetTCPConnection -LocalPort $ApiPort -ErrorAction SilentlyContinue |
    ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }

Set-Location $Server

if (-not (Test-Path ".env")) {
    Copy-Item "..\deploy\env.production.example" ".env"
    Write-Host "UYARI: .env olusturuldu — MIN_REQUIRED ve JWT duzenle!" -ForegroundColor Yellow
}

if (-not (Test-Path "node_modules")) {
    Write-Host ">> npm install..." -ForegroundColor Cyan
    npm install
}

Write-Host ">> Node: $(node -v)" -ForegroundColor Cyan
Write-Host ">> API basliyor (Ctrl+C ile dur)" -ForegroundColor Green
node src/index.js
