# Windows sunucu — GitHub'dan çek ve yeniden başlat
# Kullanım: powershell -File deploy\scripts\windows-update.ps1

$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location $Root

Write-Host ">> git pull" -ForegroundColor Cyan
git pull origin main

if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host ">> docker compose" -ForegroundColor Cyan
    Set-Location (Join-Path $Root "deploy")
    docker compose -f docker-compose.prod.yml up -d --build
    Start-Sleep -Seconds 3
    Invoke-RestMethod -Uri "http://127.0.0.1:3000/health"
} else {
    Write-Host ">> pm2 / node restart (docker yok)" -ForegroundColor Yellow
    Set-Location (Join-Path $Root "server")
    npm install
    if (Get-Command pm2 -ErrorAction SilentlyContinue) {
        pm2 restart vampir-api
    }
}

Write-Host ">> OK" -ForegroundColor Green
