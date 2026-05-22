# VPS: C:\apps\flutter  (git clone afmolla/flutter)
# Yonetici: powershell -ExecutionPolicy Bypass -File C:\apps\flutter\deploy\VPS-API-GUNCELLE.ps1

$ErrorActionPreference = "Stop"

$Candidates = @(
    "C:\apps\flutter",
    (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
)
if ($env:VPS_APP_DIR) { $Candidates = @($env:VPS_APP_DIR) + $Candidates }

$Root = $null
foreach ($c in $Candidates) {
    if (Test-Path (Join-Path $c "server\src\index.js")) {
        $Root = $c
        break
    }
}
if (-not $Root) {
    Write-Host "HATA: Proje bulunamadi. Once: git clone https://github.com/afmolla/flutter.git C:\apps\flutter" -ForegroundColor Red
    exit 1
}

$ServerDir = Join-Path $Root "server"
$StartCmd = Join-Path $ServerDir "start-api.cmd"

Write-Host "Proje: $Root" -ForegroundColor Cyan
Write-Host "Baslat: $StartCmd"

Set-Location $ServerDir
& cmd /c $StartCmd
