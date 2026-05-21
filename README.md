# Vampir Köylü

Online vampir–köylü sosyal çıkarım oyunu (6–8 oyuncu). Flutter mobil + Node.js sunucu.

**Sürüm:** `0.2.2` — Sabah giriş: [deploy/SABAH-GIRIS.md](deploy/SABAH-GIRIS.md)

## Proje yapısı

| Klasör | Açıklama |
|--------|----------|
| `mobile/` | Flutter (Android → iOS) |
| `server/` | Node.js API + WebSocket |
| `deploy/` | Docker Compose, Nginx, VPS rehberi |
| `docs/` | Oyun kuralları, sürüm politikası |
| `shared/` | API sözleşmesi |

## Hızlı başlangıç (geliştirme)

### 1. Sunucu

```bash
cd server
cp .env.example .env
npm install
npm run dev
```

Windows üretim: `server\start-api.cmd` (v0.2.2)

Sağlık: http://localhost:3000/health

### 2. Flutter (Windows)

```powershell
$env:Path = "C:\src\flutter\bin;" + $env:Path
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000
```

**Emulator:** `http://10.0.2.2:3000`  
**Fiziksel telefon:** aynı Wi‑Fi + PC IP

### 3. APK (GitHub Actions)

```bash
git tag v0.2.2 && git push origin v0.2.2
```

Releases: https://github.com/afmolla/flutter/releases

## Durum

### Sprint 0–1 (tamamlandı)

- [x] Monorepo, version API, force update + APK indir/yükle
- [x] Misafir girişi, oturum, `/api/auth/me` doğrulama
- [x] Tek oyuncu (6 kişi, botlar)
- [x] **Online oda** — oluştur, katıl, liste, Socket.io
- [x] **Online oyun** — 6–8 oyuncu, gece/gündüz, sunucu otoriter
- [x] Sabit release imzası (OTA güncelleme)

### Sonraki sprint

- [ ] Google / Facebook giriş
- [ ] PostgreSQL kalıcı kullanıcı / odalar
- [ ] Reconnect, Play Store, IAP & turnuva

## Sunucu

| OS | Rehber |
|----|--------|
| Linux VPS | [deploy/vps-setup.md](deploy/vps-setup.md) |
| **Windows** | [deploy/windows-setup.md](deploy/windows-setup.md) |

Repo: https://github.com/afmolla/flutter
