# Zorunlu güncelleme testi

## Mevcut APK (v0.1.x) ile test

Sunucuda `server/.env` dosyasını aç:

```env
MIN_REQUIRED_VERSION=0.2.0
LATEST_VERSION=0.2.0
FORCE_UPDATE=true
```

API’yi yeniden başlat (`npm run dev` veya pm2 restart).

Telefondaki **eski APK**’yı aç → **Güncelleme gerekli** ekranı gelmeli → **Güncellemeyi indir** butonu.

Kontrol URL: `http://85.95.251.204:3000/api/version?clientVersion=0.1.0&platform=android`  
→ `"allowed": false` olmalı.

## Test bitince (oyuna devam)

```env
MIN_REQUIRED_VERSION=0.1.0
```

yeniden başlat; yeni APK (v0.1.4+) ile oyna.
