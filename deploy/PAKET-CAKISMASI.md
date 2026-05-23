# Paket çakışması (Android)

## Aynı imza — üstüne kurulum

**v0.2.10, v0.2.11, v0.2.12** (ve sonrası) hep **aynı** `release.keystore` ile imzalanır.

| Kurulu sürüm | Yeni sürüm | Ne yapmalı? |
|--------------|------------|-------------|
| **0.2.10** | **0.2.12** | **Kaldırma yok** — «Güncelle (üstüne kur)» veya APK linki |
| 0.2.8 | 0.2.12 | Bir kez kaldır → 0.2.10+ kur |
| Eski debug APK | Herhangi | Bir kez kaldır |

## İndirme linkleri

- **v0.2.12:** https://github.com/afmolla/flutter/releases/download/v0.2.12/app-release.apk
- v0.2.11: https://github.com/afmolla/flutter/releases/download/v0.2.11/app-release.apk
- v0.2.10: https://github.com/afmolla/flutter/releases/download/v0.2.10/app-release.apk

## Geliştirici

- `release.keystore` — **değiştirme** (CI parmak izi kontrolü)
- SHA-256: `SIGNING_FINGERPRINT.txt`
