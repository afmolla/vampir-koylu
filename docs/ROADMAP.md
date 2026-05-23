# Vampir Köylü — Geliştirme planı

## v0.2.25 (bu sürüm)
- [x] Sağ üst coin + TL bakiye (ana sayfa, lobi, oda, turnuva)
- [x] Giriş: e-posta veya kullanıcı adı; benzersiz nick
- [x] Misafir nick: kayıtlı ad ve çevrimiçi oyuncu kontrolü
- [x] Kendinle özel DM engeli
- [x] Oyun içi sohbet önizleme (tek satır, tıkla aç)
- [x] TR/EN çeviri (giriş, oda, sohbet temel)

## v0.2.26 (sıradaki)
- [ ] Kalan ekranların tam i18n (turnuva, profil, arkadaşlar, mağaza)
- [ ] Coin/bakiye socket ile anlık güncelleme (harcama sonrası)
- [ ] Google OAuth: VPS `auth-secrets.env` doğrulama rehberi

## v0.2.27
- [ ] Turnuva UI çeviri + ödeme akışı iyileştirme
- [ ] Oda sohbet bildirim sesi (opsiyonel)
- [ ] Profil: nick değişince `nick_taken` gösterimi

## Sürekli güncelleme (OTA)
- Paket: `com.vampirkoylu.vampir_koylu` (değiştirmeyin)
- İmza: `mobile/android/signing/release.keystore` (CI ve yerel aynı)
- Yayın: `git tag v0.2.xx` + push → GitHub Actions APK → Releases
- VPS: `deploy/repo-paths.cmd` içindeki `LATEST_VERSION` + API yeniden başlat
- Kullanıcı: uygulama içi «Güncelle» → aynı imzalı APK üzerine kurulum
