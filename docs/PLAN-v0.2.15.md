# v0.2.15 — Push, Billing, WebRTC ses

## Tamamlanan

| Özellik | Açıklama |
|---------|----------|
| FCM sunucu | `FCM_SERVER_KEY` ile turnuva / davet push |
| Yerel bildirim | Günlük 19:00 bonus hatırlatması |
| Play Billing | `in_app_purchase` + `/api/payments/play/verify` |
| WebRTC ses | `flutter_webrtc` + socket sinyal (`voice:peer-joined`) |
| Sohbet moderasyonu | Uzun bas → rapor / sustur |
| Davet kodu | Profil kartı + referral uygula |
| Oda daveti | `POST /api/friends/invite-room` + socket `room:invite` |

## Deploy

- API: `0.2.15` — `BASLAT-API.cmd`
- APK tag: `v0.2.15`
- Rehber: `deploy/FCM-KURULUM.md`, `deploy/PLAY-BILLING.md`
