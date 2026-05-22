# Güncelleme testi: 0.2.4 → 0.2.5

## 0.2.4 APK indir

Önce GitHub’da **v0.2.4** tag’i ile CI build alınmalı. Hazır olunca:

**https://github.com/afmolla/flutter/releases/download/v0.2.4/app-release.apk**

(Release yoksa: Actions → android-release → tag `v0.2.4` workflow_dispatch)

## Sunucu (güncelleme sorusu için)

`start-api.cmd` ayarı:

- `MIN_REQUIRED_VERSION=0.2.4` → 0.2.4 açılır
- `LATEST_VERSION=0.2.5` → 0.2.4 açınca güncelleme ekranı gelir
- APK URL → v0.2.5

Test URL:

```
http://85.95.251.204:3000/api/version?clientVersion=0.2.4&platform=android
```

Beklenen: `"allowed": false`, `"latestVersion": "0.2.5"`

## 0.2.5 APK

**https://github.com/afmolla/flutter/releases/download/v0.2.5/app-release.apk**

## Kontrol listesi

1. 0.2.4 kur → aç → sunucu + sürüm OK → giriş
2. Tekrar aç → güncelleme ekranı (0.2.5)
3. 0.2.5 kur → rol açılışı animasyonu → oyun arka planı dönüyor
4. Gece → şafak bandı → gündüz → gece döngüsü
