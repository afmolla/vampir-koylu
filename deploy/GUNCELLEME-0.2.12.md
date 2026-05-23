# v0.2.10 → v0.2.12 güncelleme

## İmza

Aynı `release.keystore` — **paket çakışması olmamalı**.

## Yöntem 1 — Uygulama içi (0.2.10+)

1. Uygulamayı aç → güncelleme ekranı
2. **«Güncelle (üstüne kur)»** — kaldırma kutusu gerekmez
3. Kurulum iznini ver

## Yöntem 2 — Manuel APK

https://github.com/afmolla/flutter/releases/download/v0.2.12/app-release.apk

Dosyaya dokun → Kur → Mevcut uygulamanın **üzerine** yazar.

## VPS sunucu

`BASLAT-API.cmd` → `apkPublishVersion=0.2.12`, `latestVersion=0.2.12`

## «Paket çakışması» görürsen

Sadece **0.2.8 öncesi** veya farklı imzalı eski kurulumda olur → bir kez kaldır → v0.2.12 kur.
