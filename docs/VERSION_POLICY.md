# Sürüm ve zorunlu güncelleme

## Kurallar

1. `MIN_REQUIRED_VERSION` altındaki istemciler **oyuna devam edemez**.
2. Kontrol noktaları: uygulama açılışı, WebSocket bağlantısı, (ileride) odaya giriş.
3. `FORCE_UPDATE=true` iken istemcide “Atla” yok.

## Sunucu (`server/.env`)

| Değişken | Açıklama |
|----------|----------|
| `MIN_REQUIRED_VERSION` | Minimum semver (ör. `0.1.0`) |
| `LATEST_VERSION` | Mağazadaki son sürüm |
| `UPDATE_URL_ANDROID` | GitHub Releases veya Play Store linki |

## Mobil

- `AppConfig.clientVersion` — `pubspec.yaml` `version` ile uyumlu tut
- Android `versionCode`: `+` sonrası build numarası

## Yayın

1. `MIN_REQUIRED_VERSION` artır (kırıcı değişiklikte)
2. Git tag: `v0.2.0`
3. CI APK/AAB üretir
4. GitHub Releases veya Play Console
