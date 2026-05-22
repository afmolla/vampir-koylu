# Güncelleme APK

## v0.2.9

**Git tag var, GitHub Release yok** — Actions build başarısız kaldı; atlanır.

Kullanılabilir APK: **v0.2.8** → https://github.com/afmolla/flutter/releases/download/v0.2.8/app-release.apk

## v0.2.10 (sabit imza)

1. `main` + tag `v0.2.10` — Actions **Android APK Release**
2. Yeşil olunca: https://github.com/afmolla/flutter/releases/download/v0.2.10/app-release.apk
3. VPS `start-api.cmd`: `APK_PUBLISH_VERSION=0.2.10`

Eski kurulumda **bir kez kaldır** → v0.2.10 kur (aynı `release.keystore`).

## Sunucu

- `latestVersion`: hedef sürüm (uygulama güncelleme uyarısı)
- `apkPublishVersion` + `updateUrlAndroid`: **indirilebilir** APK (404 olmamalı)
