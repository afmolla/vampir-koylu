# Vampir Köylü

Online vampir–köylü sosyal çıkarım oyunu (6–8 oyuncu). Flutter mobil + Node.js sunucu.

**Sürüm:** `0.2.15` — GitHub: [afmolla/vampir-koylu](https://github.com/afmolla/vampir-koylu)

**Klasör:** `C:\inetpub\wwwroot\oyun1`  
**VPS tek başlatma:** `BASLAT-API.cmd` veya `server\start-api.cmd` — [deploy/REPO-VE-YOLLAR.md](deploy/REPO-VE-YOLLAR.md)

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

Windows / VPS: `BASLAT-API.cmd` veya `server\start-api.cmd` (port temizle + güncel sürüm)

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
git tag v0.2.3 && git push origin v0.2.3
```

Releases: https://github.com/afmolla/vampir-koylu/releases

## Durum

### Sprint 0–1 (tamamlandı)

- [x] Monorepo, version API, force update + APK indir/yükle
- [x] Misafir girişi, oturum, `/api/auth/me` doğrulama
- [x] Tek oyuncu (6 kişi, botlar)
- [x] **Online oda** — oluştur, katıl, liste, Socket.io
- [x] **Online oyun** — 6–8 oyuncu, gece/gündüz, sunucu otoriter
- [x] **SQLite** — kullanıcılar + mesajlar (`server/data/vampir_koylu.db`)
- [x] **Sohbet** — genel lobi + oda içi (`ChatPanel`, `chat:send` / `GET /api/chat/:channel`)
- [x] Test modu: 2 kişiyle oyun başlatma
- [x] Sabit release imzası (OTA güncelleme)

### Sonraki sprint

- [ ] Google / Facebook giriş
- [ ] PostgreSQL’e geçiş (opsiyonel; SQLite MVP’de aktif)
- [ ] Reconnect, Play Store, IAP & turnuva

## Sunucu

| OS | Rehber |
|----|--------|
| Linux VPS | [deploy/vps-setup.md](deploy/vps-setup.md) |
| **Windows** | [deploy/windows-setup.md](deploy/windows-setup.md) |

Repo: https://github.com/afmolla/vampir-koylu
