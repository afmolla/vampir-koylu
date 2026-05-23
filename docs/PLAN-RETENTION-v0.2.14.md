# v0.2.14 — Oyuncu tutma paketi

## Faz A — Hızlı kazanımlar ✅
- Ana sayfa canlı panel (`/api/engagement/home`, socket `live:stats`)
- **Hızlı maç** (`room:quick-match` — botlu oda, otomatik başlat)
- Günlük bonus kartı ana sayfada
- İlk maç bonusu (+50 coin, otomatik maç sonu)
- Misafir → kayıt teşviki (2+ giriş)
- Lobi: 4–8 min/max oyuncu, bot zorluğu

## Faz B — Topluluk ✅
- Arkadaş listesi (`/api/friends`)
- Davet linki kopyala (`vampir://join?ref=`)
- Referral kodu (`/api/engagement/referral`)
- Haftalık görevler + claim
- Liderlik tablosu XP / galibiyet
- Şifremi unuttum (`/api/auth/forgot-password`)
- Profil ayarları (`PATCH /api/auth/me`)
- Push token kaydı (`/api/engagement/push-token`) — FCM entegrasyonu için hazır

## Faz C — Derinlik ✅
- 4–8 oyunculu odalar
- Bot zorluğu easy/normal/hard
- Kozmetik **kuşan** (`POST /api/shop/equip`)
- Maç özeti ödül mesajı
- Sezon pass (ücretsiz + premium track, aylık XP)

## Faz D — Ekonomi ✅
- Turnuva **bakiye** ile kayıt (`method: balance`)
- Host çıkışında diğer oyunculara +15 coin iade
- Play IAP iskeleti (mevcut pending flow)

## Faz E — Güven ✅
- Küfür filtresi (sohbet)
- Rapor (`POST /api/social/report`)
- Susturma (`/api/social/mute`)

## Deploy
1. VPS: `git pull` → `BASLAT-API.cmd` (sürüm 0.2.14)
2. Tag `v0.2.14` → GitHub Actions APK
3. SMTP: `.env` → `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`, `MAIL_FROM`

## Sonraki adımlar (manuel)
- Firebase FCM + gerçek push gönderimi
- Play Billing tam entegrasyon
- WebRTC ses (sinyal altyapısı socket'te var)
- Deep link `vampir://join` Android intent filter
