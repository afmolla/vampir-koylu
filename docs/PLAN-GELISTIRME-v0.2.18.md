# Geliştirme Planı — v0.2.18+

> **v0.2.17 özeti:** Hoş geldin 1000 coin (yeni hesap/misafir), günlük +100 coin, turnuva coin kesintisi + yetersiz bakiye engeli, odada «Bot ile doldur» + tek kişiyle botlu oyun başlatma.

---

## v0.2.20 — Sohbet + ses (guncel)

- Klavye acilinca sohbet paneli kapanmiyor (sabit state, viewInsets)
- Sesli sohbet lobide + oyunda; AppBar mikrofon ikonu
- Mikrofon ac/kapa gercek WebRTC track kontrolu
- Oyun baslayinca otomatik ses kanalina katilim
- versionCode 49 — ayni imza ile uzerine kurulum

---

## v0.2.17 — Yapılanlar

| Özellik | Durum |
|---------|--------|
| Yeni kayıt / misafir → 1000 coin | ✅ `ensureProfile` |
| Günlük giriş → 100 coin | ✅ `claimDailyLogin` |
| Turnuva coin ile katılım, yetersiz coin engeli | ✅ API + mobil UI |
| Turnuva bakiye (TRY) ile katılım | ✅ API (`method: balance`) |
| Oda: «Eksikleri bot ile doldur» + «Bot ile doldur» butonu | ✅ `room:fill-bots` |
| Tek host + botlarla «Oyunu başlat» | ✅ `MIN_HUMANS_TO_START = 1` |
| Sunucu sürümü 0.2.17 | ✅ health / config |

---

## Mevcut Özellikler — Durum Kontrolü

### Çalışan (üretimde kullanılabilir)

- **Kimlik:** Misafir, e-posta kayıt/giriş, şifre sıfırlama (e-posta), Google/Facebook (env ile)
- **Online oyun:** Oda oluştur/katıl, hızlı maç, 4–8 oyuncu, bot doldurma, gece/oy verme, maç özeti
- **Ekonomi:** XP, coin, TRY bakiye, rütbe kademeleri, maç ödülleri, host çıkış cezası
- **Retention:** Günlük bonus, günlük/haftalık görevler, sezon bileti, ilk maç bonusu, referans
- **Sosyal:** Arkadaş listesi, genel/oda/ölü/vampir/DM sohbet, rapor + susturma
- **Turnuva:** Kayıt, coin kesintisi, lobi açma, turnuva odası
- **Mağaza:** Kozmetik satın al + kuşan (coin)
- **Ses:** WebRTC sinyal + yakınlık kanalı (temel)
- **Güncelleme:** Sürüm kontrolü, zorunlu güncelleme, APK sideload

### Eksik / yarım / muhtemelen çalışmıyor

| Konu | Sorun | Öncelik |
|------|--------|---------|
| **Doktor gece aksiyonu** | Sunucu `doctor_protect` var; mobil her zaman `night_kill` gönderiyor | 🔴 Yüksek |
| **Diğer rol gece yetenekleri** | `roles.js`’te tanımlı; oyun döngüsünde yok | 🟡 Orta |
| **Turnuva ödül dağıtımı** | Kazanan / prize pool DB’de; maç bitince otomatik ödeme yok | 🔴 Yüksek |
| **Turnuva + bot** | Turnuva odasında bot doldurma kapalı | 🟡 Orta |
| **Play Billing** | `payments.js` stub; gerçek Google doğrulama yok | 🔴 Yüksek |
| **IAP turnuva** | Mobilde «Test onay»; prod için uygun değil | 🔴 Yüksek |
| **Kozmetik görünüm** | Kuşanma API çalışır; avatar/oyun UI’da render yok | 🟡 Orta |
| **Rütbe perk’leri** | Gümüş +5% coin vb. metin var, kodda uygulanmıyor | 🟡 Orta |
| **Ses sustur** | Mikrofon ikonu; track gerçekten kapatılmıyor | 🟢 Düşük |
| **FCM push** | Sunucu hazır; mobil token kaydı yok | 🟡 Orta |
| **Deep link `vampir://`** | Referans linki kopyalanıyor; Android intent yok | 🟡 Orta |
| **Arkadaş oda daveti** | API var; UI’da buton yok | 🟢 Düşük |
| **Eski kullanıcı coin** | v0.2.17 öncesi hesaplarda 100 coin kalabilir | 🟢 Düşük (admin SQL) |
| **Facebook giriş** | Placeholder app id | 🟢 Düşük |
| **HTTPS API** | HTTP :3002; prod için subdomain + TLS önerilir | 🟡 Orta |

---

## v0.2.18 — Önerilen sprint (2–3 hafta)

### Faz A — Oyun kalitesi (1 hafta)

1. Doktor gece UI + `canPlayerAct` genişletmesi
2. Turnuva maç bitince kazanan + coin dağıtımı
3. Turnuva lobisinde opsiyonel bot doldurma (test modu)

### Faz B — Monetizasyon (1 hafta)

4. Google Play `purchases.products.get` doğrulama
5. Turnuva IAP akışını test onayından prod’a taşı
6. Gümüş+ rütbe coin bonusunu `applyMatchRewards`’a ekle

### Faz C — Büyüme (1 hafta)

7. FCM: `firebase_messaging` + login sonrası token kaydı
8. Android deep link + referans kodu parse
9. Arkadaş listesinden «Odaya davet et»
10. Kuşanılan çerçeve/skin’i `UserAvatar`’da göster

---

## v0.2.19+ — Orta vadeli

- HTTPS reverse proxy (`api.domain.com` → :3002)
- Kalan rol gece yetenekleri (dedektif, tuzak, vb.)
- Yakınlık sesi: mesafe / aynı «köy bölgesi» mantığı
- Turnuva bracket / çoklu tur
- iOS build + TestFlight
- Admin panel: coin bakiye düzeltme, turnuva yönetimi
- Eski `settings_screen.dart` temizliği, ölü l10n string’leri

---

## Deploy kontrol listesi (v0.2.17)

1. VPS’te API’yi yeniden başlat: `BASLAT-API.cmd` veya `server\start-api.cmd`
2. `/health` → `serverBuild: 0.2.17`, `ok: true`
3. GitHub Actions → `android-release` workflow → tag `v0.2.17`
4. APK: `https://github.com/afmolla/vampir-koylu/releases/download/v0.2.17/app-release.apk`
5. Telefonda sunucu: `http://85.95.251.204:3002` (kaydedilmiş eski URL varsa sıfırla)

### Test senaryoları

- [ ] Yeni misafir → profilde 1000 coin
- [ ] Günlük bonus → +100 coin (günde bir)
- [ ] Turnuva 75 coin → yetersizse buton pasif / hata mesajı
- [ ] Oda kur → bot ile doldur → oyunu başlat → gece/oy fazları
- [ ] Hızlı maç → otomatik bot + başlangıç

---

## Teknik borç

- `server/package.json` sürümü güncel değil (0.2.3)
- `rebuild-apks.yml` log mesajı eski tag referansı
- Eski kullanıcı coin migrasyonu için tek seferlik SQL:

```sql
UPDATE user_profiles SET coins = 1000 WHERE coins < 1000;
```

(Prod’da dikkatli kullan — gerçek harcama geçmişi olan hesapları etkileyebilir.)
