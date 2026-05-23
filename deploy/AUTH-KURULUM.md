# Google / Facebook giriş

## 1. Google Cloud Console

1. [Google Cloud Console](https://console.cloud.google.com/) → proje seç / oluştur  
2. **APIs & Services** → **OAuth consent screen** → yapılandır  
3. **Credentials** → **Create credentials** → **OAuth client ID**

### Web client (zorunlu — sunucu + mobil)

- Application type: **Web application**  
- Authorized redirect URIs: boş bırakılabilir (mobil idToken akışı)  
- Oluşan **Client ID** → `GOOGLE_CLIENT_ID` (`.apps.googleusercontent.com` ile biter)

### Android client (zorunlu — Play / release APK)

- Application type: **Android**  
- Package name: `com.vampirkoylu.vampir_koylu`  
- SHA-1 (release imza):

```cmd
keytool -list -v -keystore mobile\android\signing\release.keystore -alias vampir -storepass vampir_koylu_store -storetype PKCS12
```

`SHA1:` satırını Google Console’a yapıştır.

## 2. Sunucu (VPS)

```cmd
cd C:\inetpub\wwwroot\oyun1\server
copy auth-secrets.env.example auth-secrets.env
notepad auth-secrets.env
```

`auth-secrets.env` içine:

```env
GOOGLE_CLIENT_ID=WEB_CLIENT_ID.apps.googleusercontent.com
```

API’yi yeniden başlat:

```cmd
BASLAT-API.cmd
```

Kontrol:  
`http://85.95.251.204:3002/api/config/public`  
→ `"googleSignInEnabled": true`

## 3. Mobil

**v0.2.21+** Client ID’yi sunucudan otomatik alır (`/api/config/public`).  
Yeni APK şart değil; sunucuda `GOOGLE_CLIENT_ID` yeterli.

İsteğe bağlı APK build:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://85.95.251.204:3002 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID.apps.googleusercontent.com
```

GitHub Actions: repo **Secrets** → `GOOGLE_SERVER_CLIENT_ID` (aynı Web client ID).

## API uçları

- `GET /api/config/public` — Google Web Client ID (mobil)  
- `POST /api/auth/google` — `{ "idToken": "..." }`  
- `POST /api/auth/facebook` — `{ "accessToken": "..." }`
