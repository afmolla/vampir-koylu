# Paket çakışması (Android)

## Neden olur?

Telefonda yüklü APK ile indirilen APK **farklı imza** ile üretilmişse Android «Paket çakışması» der. Üstüne kurulum yapılamaz.

Eski GitHub build'leri CI'da **debug** imza kullanıyordu (her build farklı olabiliyordu). **v0.2.8+** sabit `release.pfx` ile imzalanır.

## Kullanıcı ne yapar? (bir kez)

Telefonda: **«Paket mevcut bir paketle çakıştığından uygulama yüklenemedi»**

1. **Ayarlar → Uygulamalar → Vampir Köylü → Kaldır**  
   veya güncelleme ekranında **Uygulamayı kaldır** (kırmızı buton)
2. Kaldırdıktan sonra kutuyu işaretle: **Uygulamayı kaldırdım**
3. **İndir ve yükle**
4. Sonraki sürümler (aynı imza) üstüne kurulur

Manuel APK: https://github.com/afmolla/flutter/releases/download/v0.2.7/app-release.apk

## Geliştirici

- `mobile/android/signing/release.pfx` + `key.properties` repoda
- Yeni APK: GitHub Actions `android-release.yml` → tag `v0.2.8`
- Sunucu: `BASLAT-API.cmd` → `latestVersion` 0.2.8
