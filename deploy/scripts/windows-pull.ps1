# Sunucuda: GitHub'dan son kodu çek (git PATH'te olmalı)
# Kullanım: powershell -File deploy\scripts\windows-pull.ps1

$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location $Root

$git = "git"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    $gitExe = "C:\Program Files\Git\cmd\git.exe"
    if (Test-Path $gitExe) { $git = $gitExe } else {
        Write-Host "Git yok. ZIP indir: https://github.com/afmolla/flutter/archive/refs/heads/main.zip" -ForegroundColor Red
        exit 1
    }
}

Write-Host ">> git pull (repo: afmolla/flutter, klasor: $Root)" -ForegroundColor Cyan
& $git pull origin main
Write-Host ">> Tamam. API yenilemek icin: npm run dev veya docker compose up -d --build" -ForegroundColor Green
