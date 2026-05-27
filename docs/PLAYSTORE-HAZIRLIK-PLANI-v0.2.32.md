## Hedef

Uygulamayı **Play Store’a yüklenebilir seviyeye** getirip, sesli sohbeti (mikrofon aç → ses gönder → ses al) gerçek cihazlarda stabil çalıştırmak. Ayrıca yeni sürüm çıktığında uygulama **bip sesli bildirim** ile haber versin.

---

## 1) Sesli sohbet (kritik) — doğrulama + sağlamlaştırma

Mevcut altyapı:
- **Client**: `mobile/lib/services/voice_rtc_manager.dart`, `mobile/lib/widgets/voice_chat_strip.dart`
- **Server relay**: `server/src/socket.js` (`voice:join`, `voice:leave`, `voice:signal`)
- **ICE/TURN**: `server/src/routes/publicConfig.js` → `iceServers`, client `AuthConfig.iceServers`

### 1.1 Test senaryoları (gerçek cihaz, 4G/Wi-Fi)
- **2 cihaz, aynı oda**:
  - A mikrofon açık → B duyuyor mu?
  - B mikrofon kapalı/açık toggle → track gidiyor mu?
  - A/B sırayla join/leave → `peer-joined/peer-left` düzgün mü?
- **NAT/operatör senaryosu**:
  - Farklı internet (biri Wi-Fi, biri 4G) → bağlanıyor mu?
  - Bağlanmıyorsa TURN zorunlu (aşağıdaki 1.2).
- **Edge**:
  - Oyun ekranından çık/küçült → ses kapanıyor mu?
  - Socket reconnect sonrası tekrar join → ses geri geliyor mu?

### 1.2 TURN üretim ayarı (çoğu zaman şart)
- VPS `.env`:
  - `TURN_URL=turn:...:3478` (veya `turns:` TLS)
  - `TURN_USERNAME=...`
  - `TURN_CREDENTIAL=...`
- Sonra `GET /api/config/public` ile `iceServers` doğrula.

### 1.3 UX / hata mesajı
- Join başarısız olursa kullanıcıya net mesaj:
  - “Mikrofon izni gerekli”
  - “Ağ/TURN nedeniyle bağlantı kurulamadı (tekrar dene)”

---

## 2) Güncelleme bildirimi (bip)

Hedef: Sunucu `latestVersion` > client ise uygulama açıldığında **tek seferlik** bildirim atsın.

Uygulama:
- `LocalNotificationsService.notifyUpdateAvailable()` eklendi (kanal: `update_available`)
- `SplashScreen` sürüm kontrolünden sonra update varsa tetikliyor
- Aynı sürüm için tekrar bildirim spam’i yok (prefs ile tutuluyor)

Not: Play Store’a geçince “APK indir” yerine “Store’a git” linki planlanmalı.

---

## 3) Play Store “yüklenebilir” checklist

### 3.1 Paket / imzalama
- `applicationId` sabit
- Release keystore güvenli
- `version`/`versionCode` artışı

### 3.2 İzinler
- Mikrofon: gerekçeli (sesli sohbet)
- Bildirim: günlük bonus + güncelleme (kullanıcı kontrolü)
- Kamera/galeri: profil fotoğrafı (opsiyonel)

### 3.3 Politika / kullanıcı güveni
- Uygulama içi “Gizlilik / KVKK” linki (min)
- Hesap silme akışı (ileride)

### 3.4 Kalite
- Crash-free hedefi
- Ağ hatalarında güvenli fallback
- Minimum cihaz testi: Android 10–14, düşük RAM

---

## 4) Yayın akışı (v0.2.32)
- `mobile/pubspec.yaml` sürüm bump
- Tag `v0.2.32`
- GitHub Actions → AAB/APK build
- VPS: `git pull` + restart
- Play Console: AAB yükle, internal test → closed → production

