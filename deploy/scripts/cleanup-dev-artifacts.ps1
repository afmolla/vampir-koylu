# Yerel disk temizligi — kaynak kodu ve ozellikleri etkilemez.
# Silinen: Flutter build, .dart_tool, Android Gradle onbellegi.
# Sonra mobil: flutter pub get | sunucu: npm ci (server klasorunde)

$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$mobile = Join-Path $root 'mobile'

Write-Host "Temizlik: $root"

if (Get-Command flutter -ErrorAction SilentlyContinue) {
  Push-Location $mobile
  flutter clean
  Pop-Location
} else {
  Write-Warning 'flutter yok; klasorler elle siliniyor.'
  @('build', '.dart_tool') | ForEach-Object {
    $p = Join-Path $mobile $_
    if (Test-Path $p) { Remove-Item -Recurse -Force $p }
  }
}

@(
  'mobile\android\.gradle',
  'mobile\android\app\build',
  'mobile\android\build',
  'mobile\android\.cxx'
) | ForEach-Object {
  $p = Join-Path $root $_
  if (Test-Path $p) { Remove-Item -Recurse -Force $p; Write-Host "Silindi: $_" }
}

$total = (Get-ChildItem $root -Recurse -Force -EA SilentlyContinue | Measure-Object Length -Sum).Sum
Write-Host "Kalan boyut: $([math]::Round($total / 1MB, 1)) MB"
Write-Host 'Mobil derleme icin: cd mobile && flutter pub get && flutter build apk'
Write-Host 'API icin: cd server && npm ci'
