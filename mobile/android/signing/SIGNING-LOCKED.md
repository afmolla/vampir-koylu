# Kalıcı APK imzası (KİLİTLİ)

**Bu dosyaları değiştirme** — aksi halde kullanıcılar «paket çakışması» görür.

| Dosya | Açıklama |
|--------|-----------|
| `release.keystore` | Tek resmi imza (CI + yerel build) |
| `release.pfx` | Yedek kaynak (aynı anahtar) |
| `SIGNING_FINGERPRINT.txt` | SHA-256 doğrulama |

Şifreler: `mobile/android/key.properties` (repoda).

## Yeni APK üretimi

GitHub Actions `android-release.yml` — her build parmak izini kontrol eder.

## Eski kurulum (bir kez)

Telefonda **farklı imzalı** eski Vampir Köylü varsa:

1. Uygulamayı **kaldır**
2. En yeni APK kur
3. Sonraki tüm güncellemeler **üstüne** kurulur

## Asla yapma

- `keytool -genkeypair` ile yeni keystore
- CI cache’den rastgele yeni anahtar
- `release.pfx` / `release.keystore` silip yeniden üretme

Yenileme gerekirse: tüm kullanıcılara «bir kez kaldırın» duyurusu + yeni kilitleme.
