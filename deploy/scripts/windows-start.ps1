# Windows — API'yi başlat (geliştirme)
# Kullanım: powershell -ExecutionPolicy Bypass -File deploy\scripts\windows-start.ps1

$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$Server = Join-Path $Root "server"

if (-not (Test-Path (Join-Path $Server ".env"))) {
    Copy-Item (Join-Path $Root "deploy\env.production.example") (Join-Path $Server ".env")
    Write-Host "server\.env oluşturuldu — JWT_SECRET düzenle!" -ForegroundColor Yellow
}

Set-Location $Server
if (-not (Test-Path "node_modules")) {
    npm install
}

Write-Host "API: http://127.0.0.1:3000/health" -ForegroundColor Green
npm run dev
