# Paket çakışması (Android)

## Neden olur?

Eski APK'lar **farklı imza** ile kurulmuştu. Android üstüne farklı imzalı güncellemeye izin vermez.

**v0.2.10+** tüm build'ler **aynı** `release.keystore` ile imzalanır (repoda kilitli, CI yeni anahtar üretmez).

## Kullanıcı — bir kez

1. **Vampir Köylü → Kaldır**
2. **v0.2.10** kur: https://github.com/afmolla/flutter/releases/download/v0.2.10/app-release.apk
3. Sonraki güncellemeler **üstüne** kurulur (çakışma yok)

## Geliştirici — imzayı değiştirme

- `mobile/android/signing/release.keystore` — **KİLİTLİ**
- `SIGNING_FINGERPRINT.txt` — CI doğrular
- `SIGNING-LOCKED.md` — kurallar

Yeni APK: tag `v0.2.10` → `android-release.yml`
