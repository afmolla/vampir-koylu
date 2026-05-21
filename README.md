# Vampir Köylü

Online vampir–köylü sosyal çıkarım oyunu (6–8 oyuncu). Flutter mobil + Node.js sunucu.

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

Sağlık kontrolü: http://localhost:3000/health

### 2. Flutter (Windows)

Flutter SDK bu makinede `C:\src\flutter` altına kuruldu. PATH’e ekle:

```powershell
$env:Path = "C:\src\flutter\bin;" + $env:Path
```

```bash
cd mobile
flutter pub get
flutter run
```

**Emulator API adresi:** `http://10.0.2.2:3000` (varsayılan `lib/core/config.dart`)

**Fiziksel telefon:** Bilgisayar IP’n ile:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000
```

### 3. Zorunlu güncelleme testi

`server/.env` içinde `MIN_REQUIRED_VERSION=99.0.0` yap → uygulama güncelleme ekranında kalır.

## GitHub

Repo: **https://github.com/afmolla/flutter**

`v*` tag push edildiğinde GitHub Actions APK üretir (workflow: `.github/workflows/android-release.yml`).

## VPS

Bkz. [deploy/vps-setup.md](deploy/vps-setup.md)

## Durum (Sprint 0)

- [x] Monorepo iskeleti
- [x] Version API + force update ekranı
- [x] Misafir nick girişi
- [ ] Google / Facebook giriş
- [ ] Oyun odası 6–8
- [ ] IAP & turnuva
