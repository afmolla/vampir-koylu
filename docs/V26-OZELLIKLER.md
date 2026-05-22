# v0.2.6 — Sesli sohbet, roller, rank, kozmetik, görevler

## Bu sürümde (temel altyapı)

### Sohbet kanalları
| Kanal | Kim |
|--------|-----|
| `room:KOD` | Canlı oyuncular |
| `dead:KOD` | Ölüler |
| `vampire:KOD` | Gece — vampir takımı |
| `proximity:KOD` | Yakın ses (beta, WebRTC sinyal relay) |

### Roller (6–8 kişi)
Vampir, Sessiz katil, Çifte ajan, Doktor, Kahin, Avcı, Koruyucu, Şerif, Büyücü, Lanetli köylü, Deli, Köylü

### Rank (XP — kozmetik, pay-to-win yok)
Bronze → Silver → Gold → Immortal Vampire

### Mağaza (sadece görünüm)
Skin, kan efekti, mezarlık teması, çerçeve, ölüm animasyonu

### Günlük
- Giriş bonusu (`POST /api/profile/daily-login`)
- Görevler: 3 maç kazan, 2 kandır, doktor kurtar

### Maç sonu özeti
Öldürmeler, yalanlar, en suçlanan, MVP

## API
- `GET /api/profile/me`
- `POST /api/profile/daily-login`
- `POST /api/profile/quests/:id/claim`
- `GET /api/shop/catalog`
- `POST /api/shop/purchase` — `cosmeticOnly: true`

## Sonraki adımlar (v0.2.7+)
- Tam WebRTC ses + yakınlık mesafesi
- Tüm roller için gece yetenekleri (kahin gör, avcı intikam)
- Seer/sheriff investigate UI
- IAP entegrasyonu (Google Play)

## APK
https://github.com/afmolla/flutter/releases/download/v0.2.6/app-release.apk
