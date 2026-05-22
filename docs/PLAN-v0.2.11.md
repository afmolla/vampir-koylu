# v0.2.11 — Uygulama planı

**Hedef sürüm:** `0.2.11+39`  
**APK (şu an):** v0.2.10 yayında (~54 MB) — v0.2.11 tag ile yenilenecek.

---

## Faz 1 — Oyun & sohbet & güncelleme (bu sprint)

| # | Özellik | Durum |
|---|---------|--------|
| 1.1 | Ölüler oda + ölüler kanalında yazabilsin | ✅ |
| 1.2 | Min 6 oyuncu; 2–8 yerine 6–8 oda | ✅ |
| 1.3 | «Bot ile doldur» — 2 insan + bot = 6 | ✅ |
| 1.4 | Kurucu oyundan çıkınca coin cezası + oyun iptal | ✅ |
| 1.5 | Maça giriş coin/XP; kazanana ekstra ödül | ✅ |
| 1.6 | Giriş sonrası genel sohbet (ana sayfa) | ✅ |
| 1.7 | APK indirme: yedek URL + tarayıcı fallback | ✅ |
| 1.8 | Mikrofon izni manifest (ses hazırlığı) | ✅ |

---

## Faz 2 — Hesap & profil

| # | Özellik |
|---|---------|
| 2.1 | DB: `email`, `password_hash`, `avatar_url`, `google_id`, `facebook_id` |
| 2.2 | `POST /api/auth/register`, `/login`, `/forgot-password` (SMTP) |
| 2.3 | «Beni hatırla» — splash JWT → Home |
| 2.4 | Google Sign-In + sunucu token doğrulama |
| 2.5 | Facebook Login + sunucu token doğrulama |
| 2.6 | **Profil ayarları:** şifre değiştir, avatar (galeri/kamera), nick, dil |
| 2.7 | Şifremi unuttum → e-posta + reset link/token |

**E-posta:** VPS `.env` → `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`, `MAIL_FROM` (SendGrid / Gmail uygulama şifresi).

---

## Faz 3 — Ses (WebRTC)

| # | Özellik |
|---|---------|
| 3.1 | `RECORD_AUDIO` + runtime izin |
| 3.2 | `flutter_webrtc` — proximity kanalı |
| 3.3 | `voice:signal` client dinleyicisi |
| 3.4 | İlk açılışta «Mikrofon izni» bilgi diyaloğu |

---

## Faz 4 — Ek öneriler

- Oyun içi rapor / susturma
- Push bildirim (maç daveti)
- Host çıkışında diğer oyunculara iade (kısmi coin)
- Bot zorluk seviyesi (kolay / normal)
- Play Store In-App (turnuva)

---

## Sürüm & deploy

1. `main` push → tag `v0.2.11` → Actions yeşil
2. VPS: `BASLAT-API.cmd` → `latestVersion` / `apkPublishVersion` 0.2.11
3. İlk kurulum: eski imzalı APK varsa bir kez kaldır → v0.2.11

---

## Uygulama sırası

```
Faz 1 (kod) → tag v0.2.11 → Faz 2 auth DB+API → Faz 2 mobile → Faz 3 ses
```
