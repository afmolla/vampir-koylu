# Vampir Köylü — Güncelleme planı (v0.2.28+)

Önceki sürümlerle uyumlu; küçük adımlar, OTA ile dağıtım.

## v0.2.28 — Yönetici paneli (bu sürüm)
- [x] `afmolla` (ve `ADMIN_NICKS`) girişinde **Üyeler** sekmesi
- [x] Kayıtlı üyeler / misafirler / arama / sayfalama
- [x] API: `GET /api/admin-panel/users` (JWT + yönetici kontrolü)

## v0.2.29 — Oyun deneyimi
- [ ] Kalan ekranlar i18n (turnuva, profil, arkadaşlar)
- [ ] Coin/bakiye anlık güncelleme (socket veya profil yenileme)
- [ ] Oda bildirimleri (sohbet sesi opsiyonel)

## v0.2.30 — Sosyal ve turnuva
- [ ] Turnuva UI çeviri + ödeme akışı
- [ ] Profil nick değişimi `nick_taken` mesajı
- [ ] Arkadaş listesi iyileştirme

## v0.2.31 — Ses ve stabilite
- [ ] WebRTC TURN (NAT arkası ses)
- [ ] Google OAuth VPS kontrol listesi otomatik health uyarısı

## Sürekli kurallar
- Paket: `com.vampirkoylu.vampir_koylu`
- İmza: `mobile/android/signing/release.keystore`
- Yayın: `git tag v0.2.xx` → GitHub Actions → VPS `BASLAT-API.cmd`
