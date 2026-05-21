# Windows sunucu kurulumu

**GitHub repo (Vampir Köylü projesi):** https://github.com/afmolla/flutter  

> Bu link Flutter SDK değil — oyun + API kodunun olduğu repodur.  
> Repoyu bilgisayarda istediğin klasör adına klonlayabilirsin (`vampir-koylu` önerilir).

---

## 0) Git kurulu değilse (`git is not recognized`)

`git clone` çalışmıyorsa önce **Git for Windows** kur:

### Yol 1 — winget (önerilen)

PowerShell veya CMD (**Yönetici**):

```powershell
winget install --id Git.Git -e --source winget
```

Kurulum bitince **terminali kapat ve yeniden aç**, sonra:

```powershell
git --version
```

### Yol 2 — İndir

https://git-scm.com/download/win → Next → **“Git from the command line and also from 3rd-party software”** seç → kur.

### Yol 3 — Git yok, ZIP ile al (geçici)

1. Tarayıcıda aç: https://github.com/afmolla/flutter/archive/refs/heads/main.zip  
2. ZIP’i `C:\apps\` altına çıkar  
3. Klasör adı `flutter-main` olur → yeniden adlandır: `vampir-koylu`  
4. Sonra `cd C:\apps\vampir-koylu` ile devam et (clone adımlarını atla)

> ZIP ile güncelleme için her seferinde yeni ZIP indirmen gerekir; kalıcı çözüm **Git kurmak**.

### Git yüklü ama `git is not recognized` (PATH sorunu)

Kurulu olur; CMD sadece PATH’te arar. **Yeni kurulumdan sonra eski pencereyi kapat.**

**1) Tam yol ile dene (çoğu sunucuda çalışır):**

```powershell
& "C:\Program Files\Git\cmd\git.exe" --version
```

**2) Çalışıyorsa clone da böyle:**

```powershell
cd C:\apps
& "C:\Program Files\Git\cmd\git.exe" clone https://github.com/afmolla/flutter.git vampir-koylu
```

**3) Kalıcı PATH (bir kez, sonra yeni terminal):**

```powershell
[Environment]::SetEnvironmentVariable(
  "Path",
  $env:Path + ";C:\Program Files\Git\cmd",
  "User"
)
```

Oturumu kapat / yeni CMD aç → `git --version`

**4) Teşhis scripti:**

```powershell
powershell -ExecutionPolicy Bypass -File C:\apps\vampir-koylu\deploy\scripts\windows-find-git.ps1
```

(ZIP henüz yoksa scripti indirdiğin klasörden çalıştır.)

---

Linux VPS yerine **Windows Server** veya **Windows 10/11** (7/24 açık) kullanabilirsin. Mobil uygulama `https://api.senindomain.com` veya sunucu IP’si ile bağlanır.

## Linux vs Windows (kısa)

| | Linux VPS | Windows sunucu |
|---|-----------|----------------|
| Maliyet / hosting | Ucuz, yaygın | Genelde pahalı (lisans) |
| Node.js + Socket.io | Çok yaygın | Sorunsuz çalışır |
| SSL | Certbot + Nginx | win-acme veya Cloudflare |
| Öneri | Production için ideal | Zaten Windows varsa OK |

---

## Seçenek A — Docker Desktop (en kolay)

### 1) Kur

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- Kurulum WSL2 isteyebilir — kabul et.

### 2) Projeyi GitHub’dan al

```powershell
mkdir C:\apps -ErrorAction SilentlyContinue
cd C:\apps
git clone https://github.com/afmolla/flutter.git vampir-koylu
cd vampir-koylu
copy deploy\env.production.example server\.env
notepad server\.env
```

`server\.env` içinde mutlaka düzenle:

- `JWT_SECRET` → `openssl rand -hex 32` veya uzun rastgele metin  
- `UPDATE_URL_ANDROID` → `https://github.com/afmolla/flutter/releases/latest`  
- `DATABASE_URL` → Docker’daki postgres şifresi ile aynı

### 3) Çalıştır

```powershell
cd C:\apps\vampir-koylu\deploy
$env:POSTGRES_PASSWORD = "GÜÇLÜ_ŞİFRE"
docker compose -f docker-compose.prod.yml up -d --build
curl http://127.0.0.1:3000/health
```

Beklenen: `{"ok":true,"service":"vampir-koylu-server"}`

### 4) İnternetten erişim

- Güvenlik duvarı: TCP **3000** veya (tercihen) sadece **80/443** + reverse proxy  
- Router port yönlendirme: 443 → bu PC  
- Domain **A kaydı** → sunucu IP (evdeysen DDNS gerekebilir)

Mobil APK (production API):

```powershell
cd C:\apps\vampir-koylu\mobile
flutter build apk --release --dart-define=API_BASE_URL=https://api.senindomain.com
```

---

## Seçenek B — Docker yok, sadece Node

### 1) Node 20 LTS

https://nodejs.org/

### 2) Proje

```powershell
cd C:\apps
git clone https://github.com/afmolla/flutter.git vampir-koylu
cd vampir-koylu\server
copy ..\deploy\env.production.example .env
notepad .env
npm install
```

MVP’de Postgres şart değil (misafir giriş bellekte).

### 3) Çalıştır

```powershell
npm run dev
```

**Sürekli çalışsın (PM2):**

```powershell
npm install -g pm2
cd C:\apps\vampir-koylu\server
pm2 start src/index.js --name vampir-api
pm2 save
pm2 startup
```

### 4) HTTPS

- [win-acme](https://www.win-acme.com/) (Let’s Encrypt)  
- veya **Cloudflare** → SSL orada, arkaya `http://127.0.0.1:3000`

---

## Güvenlik duvarı

PowerShell (Yönetici):

```powershell
New-NetFirewallRule -DisplayName "Vampir API 3000" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
```

Production: mümkünse API’yi sadece `127.0.0.1:3000`’de tut, dışarıya Nginx/IIS + 443 aç.

---

## Mobil — API adresi

| Ortam | `API_BASE_URL` |
|--------|----------------|
| Android emülatör (aynı PC) | `http://10.0.2.2:3000` |
| Telefon, aynı Wi‑Fi | `http://192.168.x.x:3000` |
| İnternet + domain | `https://api.senindomain.com` |

> `10.0.2.2` PC tarayıcısında **çalışmaz** — sadece emülatör içindir.

---

## GitHub’dan güncelleme

PC’de push:

```powershell
cd C:\apps\vampir-koylu
git add .
git commit -m "mesaj"
git push origin main
```

Sunucuda çek:

```powershell
powershell -ExecutionPolicy Bypass -File C:\apps\vampir-koylu\deploy\scripts\windows-update.ps1
```

**Otomatik (push → sunucu):** https://github.com/afmolla/flutter/blob/main/deploy/github-deploy.md  

GitHub → repo **Settings → Secrets → Actions** → `SSH_HOST`, `SSH_USER`, `SSH_KEY`, `DEPLOY_PATH`

---

## APK yayını (GitHub Releases)

```powershell
git tag v0.1.0
git push origin v0.1.0
```

APK: https://github.com/afmolla/flutter/releases

---

## Dikkat

- Ev interneti **dinamik IP** → DDNS veya sabit IP  
- PC uyursa/kapanırsa API düşer → PM2 veya Docker `restart: unless-stopped`  
- `JWT_SECRET` ve şifreleri GitHub’a **commit etme**
