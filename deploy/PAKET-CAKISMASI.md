# Paket çakışması (Android)

## Neden olur?

Telefonda yüklü APK ile indirilen APK **farklı imza** ile üretilmişse Android «Paket çakışması» der. Üstüne kurulum yapılamaz.

Eski GitHub build'leri CI'da **debug** imza kullanıyordu (her build farklı olabiliyordu). **v0.2.8+** sabit `release.pfx` ile imzalanır.

## Kullanıcı ne yapar? (bir kez)

1. Uygulamada güncelleme ekranı → **Uygulamayı kaldır (ayarlar)**
2. Ayarlarda **Kaldır**
3. **İndir ve yükle** → v0.2.8
4. Sonraki sürümler doğrudan güncellenir

## Geliştirici

- `mobile/android/signing/release.pfx` + `key.properties` repoda
- Yeni APK: GitHub Actions `android-release.yml` → tag `v0.2.8`
- Sunucu: `BASLAT-API.cmd` → `latestVersion` 0.2.8
