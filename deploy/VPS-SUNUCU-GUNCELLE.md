# VPS sunucuyu güncelle (güncelleme ekranı için ZORUNLU)

Canlı sunucuda şu an eski ayar olabilir: `MIN=0.2.0` → **0.2.2 APK güncelleme görmez.**

## Hızlı fix (5 dk)

1. GitHub ZIP veya `server` klasörünü `C:\apps\vampir-koylu\server` üzerine kopyala.
2. CMD:
   ```
   cd C:\apps\vampir-koylu\server
   npm install
   start-api.cmd
   ```
3. Pencerede şunları gör:
   ```
   MIN_REQUIRED_VERSION=0.2.3
   LATEST_VERSION=0.2.3
   UPDATE_URL_ANDROID=.../v0.2.3/app-release.apk
   ```
4. Test (PC tarayıcı):
   ```
   http://85.95.251.204:3000/api/version?clientVersion=0.2.2&platform=android
   ```
   Beklenen: `"allowed": false`, `"latestVersion": "0.2.3"`

5. Telefonda uygulamayı kapat-aç → güncelleme ekranı gelmeli.

## Eski API çalışıyorsa

Port 3000’i tutan eski `node` sürecini kapat (`start-api.cmd` bunu yapar).
