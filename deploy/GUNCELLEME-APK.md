# Güncelleme / APK sorunları

## v0.2.9 APK yoksa (404)

GitHub Actions `v0.2.9` build başarısız veya henüz bitmemiş olabilir.

**Sunucu** `APK_PUBLISH_VERSION=0.2.8` ile **çalışan** APK linki döner; uygulama `latestVersion` yine 0.2.9 olabilir.

Kontrol:

- https://github.com/afmolla/flutter/releases/download/v0.2.8/app-release.apk → 200 OK
- https://github.com/afmolla/flutter/releases/download/v0.2.9/app-release.apk → 404 ise Actions tetikle

## VPS

```cmd
C:\apps\flutter\BASLAT-API.cmd
```

`.env` içinde `APK_PUBLISH_VERSION=0.2.8` olmalı.

## GitHub Actions yeniden build

Actions → **Android APK Release** → Run workflow → tag `v0.2.9`

Yeşil olunca v0.2.9 APK yayınlanır; sonra sunucuda `APK_PUBLISH_VERSION=0.2.9` yapılır.

## Paket çakışması

Eski kurulumu kaldır → yeni APK kur. Aynı imza ile sonraki güncellemeler üstüne kurulur.
