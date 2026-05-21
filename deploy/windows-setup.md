# Windows sunucu kurulumu

Linux VPS yerine **Windows Server** veya güçlü bir **Windows 10/11** makine (7/24 açık) kullanabilirsin. Mobil uygulama yine `https://api.domain.com` veya IP ile bağlanır.

## Linux vs Windows (kısa)

| | Linux VPS | Windows sunucu |
|---|-----------|----------------|
| Maliyet / hosting | Ucuz, yaygın | Genelde pahalı (lisans) |
| Node.js + Socket.io | Çok yaygın | Sorunsuz çalışır |
| SSL / Nginx | Kolay (Certbot) | win-acme veya Cloudflare |
| Öneri | Production için ideal | Evde / zaten Windows varsa OK |

---

## Seçenek A — Docker Desktop (en kolay)

### 1) Kur

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- WSL2 etkin olsun (Docker kurulumu sorar)

### 2) Projeyi al

```powershell
cd C:\apps
git clone https://github.com/afmolla/flutter.git vampir-koylu
cd vampir-koylu
copy deploy\env.production.example server\.env
notepad server\.env
```

`JWT_SECRET`, `DATABASE_URL` düzenle (`postgres` host adı Docker içinde aynı kalır).

### 3) Çalıştır

```powershell
cd C:\apps\vampir-koylu\deploy
$env:POSTGRES_PASSWORD = "GÜÇLÜ_ŞİFRE"
docker compose -f docker-compose.prod.yml up -d --build
curl http://127.0.0.1:3000/health
```

### 4) Dışarıya aç

- Windows Güvenlik Duvarı → **Gelen** kural → TCP **3000** (veya sadece 80/443 reverse proxy ile)
- Router’da port yönlendirme: 443 → bu PC
- Domain A kaydı → ev IP (dinamik IP ise DDNS)

Mobil build:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://api.senindomain.com
```

---

## Seçenek B — Docker yok, doğrudan Node (hafif)

### 1) Node 20 LTS kur

https://nodejs.org/

### 2) Proje

```powershell
cd C:\apps\vampir-koylu\server
copy ..\.env.example .env
# veya deploy\env.production.example → .env
notepad .env
npm install
```

`.env` içinde Postgres kullanmayacaksan MVP için `DATABASE_URL` satırını yorumda bırakabilirsin (şu an auth bellekte).

### 3) Çalıştır / arka planda tut

```powershell
npm run dev
# veya production:
$env:NODE_ENV="production"
node src/index.js
```

**PM2 (önerilir — çökünce yeniden başlar):**

```powershell
npm install -g pm2
cd C:\apps\vampir-koylu\server
pm2 start src/index.js --name vampir-api
pm2 save
pm2 startup
```

### 4) HTTPS (Windows)

**win-acme** (Let's Encrypt, ücretsiz): https://www.win-acme.com/

- IIS veya nginx for Windows önüne koy
- Ya da **Cloudflare** proxy: domain Cloudflare’de, SSL orada, arkaya `http://SUNUCU_IP:3000`

**nginx for Windows** (opsiyonel reverse proxy):

- https://nginx.org/en/download.html
- `deploy/nginx-site.conf` mantığını `127.0.0.1:3000` proxy ile kullan

---

## Güvenlik duvarı (Windows)

PowerShell (Yönetici):

```powershell
New-NetFirewallRule -DisplayName "Vampir API 3000" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
```

Production’da mümkünse sadece **80/443** aç; 3000’i sadece localhost’ta bırak (nginx arkasında).

---

## Mobil uygulama adresleri

| Ortam | API_BASE_URL |
|--------|----------------|
| Aynı PC emülatör | `http://10.0.2.2:3000` |
| Aynı ağ telefon | `http://192.168.x.x:3000` |
| İnternet + domain | `https://api.senindomain.com` |
| İnternet + sadece IP | `http://SUNUCU_IP:3000` (HTTPS şart değil ama Play için HTTPS önerilir) |

---

## Güncelleme (GitHub'dan çek)

```powershell
powershell -File C:\apps\vampir-koylu\deploy\scripts\windows-update.ps1
```

Otomatik deploy: [deploy/github-deploy.md](github-deploy.md) → GitHub Actions + SSH Secrets.

---

## Dikkat

- Ev internetinde **dinamik IP** değişir → DDNS veya sabit IP
- PC kapanırsa oyun offline → 7/24 için VPS veya always-on makine
- Windows Update yeniden başlatır → PM2 / Docker `restart: unless-stopped`
