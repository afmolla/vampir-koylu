# Google / Facebook giriş

## Sunucu (.env veya start-api ortamı)

```env
GOOGLE_CLIENT_ID=xxxxx.apps.googleusercontent.com
FACEBOOK_APP_ID=123456789
FACEBOOK_APP_SECRET=xxxxx
```

`BASLAT-API.cmd` sonrası `server\.env` dosyasına ekle ve API’yi yeniden başlat.

## Android APK build

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://85.95.251.204:3000 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID.apps.googleusercontent.com
```

Facebook: `android/app/src/main/res/values/strings.xml` içine `facebook_app_id` (flutter_facebook_auth dokümantasyonu).

## API uçları

- `POST /api/auth/register` — email, password, nick
- `POST /api/auth/login` — email, password
- `POST /api/auth/google` — `{ "idToken": "..." }`
- `POST /api/auth/facebook` — `{ "accessToken": "..." }`
- `POST /api/auth/guest` — misafir (avatar otomatik)
