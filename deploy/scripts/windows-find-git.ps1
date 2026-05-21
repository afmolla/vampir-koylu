# Git kurulu mu, PATH'te mi? — Sunucuda çalıştır:
# powershell -ExecutionPolicy Bypass -File deploy\scripts\windows-find-git.ps1

Write-Host "=== Git arama ===" -ForegroundColor Cyan

$paths = @(
    "C:\Program Files\Git\cmd\git.exe",
    "C:\Program Files (x86)\Git\cmd\git.exe",
    "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
)

$found = $null
foreach ($p in $paths) {
    if (Test-Path $p) {
        $found = $p
        Write-Host "BULUNDU: $p" -ForegroundColor Green
        & $p --version
    }
}

if (-not $found) {
    Write-Host "Standart konumlarda git.exe yok. where.exe deneniyor..." -ForegroundColor Yellow
    $where = where.exe git 2>$null
    if ($where) {
        Write-Host "where: $where" -ForegroundColor Green
        & git --version
    } else {
        Write-Host "Git PATH'te gorunmuyor. Kur: winget install Git.Git veya git-scm.com" -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "PATH'e ekle (Kullanici), sonra YENI terminal ac:" -ForegroundColor Yellow
    $gitCmd = Split-Path $found -Parent
    Write-Host "[Environment]::SetEnvironmentVariable('Path', `$env:Path + ';$gitCmd', 'User')"
}

Write-Host ""
Write-Host "PATH (git iceriyor mu):" -ForegroundColor Cyan
$env:Path -split ';' | Where-Object { $_ -match 'git' -or $_ -match 'Git' }
