# Push bildirimleri (FCM)

## Sunucu

`.env` veya `start-api.cmd`:

```
FCM_SERVER_KEY=AAAA...firebase_server_key...
```

Firebase Console → Project Settings → Cloud Messaging → **Legacy server key**

Otomatik gönderim:
- Turnuva lobisi açılınca kayıtlı oyunculara
- Arkadaş oda daveti (`POST /api/friends/invite-room`)

## Mobil (yerel hatırlatma — kurulum gerektirmez)

Giriş sonrası her gün **19:00** yerel bildirim: «Günlük bonusunu al».

## İleride: Firebase SDK

Tam uzaktan push için:
1. Firebase projesi + `google-services.json` → `mobile/android/app/`
2. `flutterfire configure`
3. Token `POST /api/engagement/push-token` ile kayıt

CI şu an Firebase olmadan derlenir; yerel bildirimler çalışır.
