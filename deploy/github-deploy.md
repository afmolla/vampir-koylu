# GitHub → Sunucuya çekme

Repo (GitHub’daki isim): **https://github.com/afmolla/vampir-koylu**  
**VPS önerilen yol:** `C:\apps\vampir-koylu` (GitHub repoyla aynı isim)

```powershell
git clone https://github.com/afmolla/vampir-koylu.git C:\apps\vampir-koylu
cd C:\apps\vampir-koylu
.\BASLAT-API.cmd
```

İçerik: `mobile/`, `server/`, `deploy/`. Yol ayarı: `deploy\repo-paths.cmd` — [REPO-VE-YOLLAR.md](REPO-VE-YOLLAR.md)

---

## Otomatik çekiyor mu?

**Şu an hayır** — bilerek kapalı (SSH secrets yokken her push’ta “run failed” maili geliyordu).

| Yöntem | Otomatik mi? |
|--------|----------------|
| `git push` → sunucu kendisi günceller | **Kapalı** (Secrets + Run workflow gerekir) |
| Sunucuda `git pull` / `vps-update.sh` | **Manuel** — sen çalıştırırsın |
| GitHub Actions → Deploy API to VPS | **Elle** (Actions → Run workflow) |

Üç yol var; çoğu ekip **A** ile başlar, Secrets kurunca **C**’ye geçer.

---

## A) Manuel `git pull` (en basit)

Sunucuda **bir kez** klonla:

```bash
# Linux
cd /opt
git clone https://github.com/afmolla/vampir-koylu.git vampir-koylu
cd vampir-koylu
# .env ayarla, docker up (vps-setup.md)
```

Her güncellemede (PC’de `git push` yaptıktan sonra) sunucuda:

```bash
cd /opt/vampir-koylu
bash deploy/scripts/vps-update.sh
```

**Windows sunucu:**

```powershell
cd C:\apps\vampir-koylu
git pull origin main
cd deploy
docker compose -f docker-compose.prod.yml up -d --build
```

---

## B) Özel GitHub token ile HTTPS pull (şifresiz komut)

Private repo olsa bile sunucuda token kullanılır (token’ı GitHub’a commit etme).

1. GitHub → Settings → Developer settings → **Fine-grained token** (repo read)
2. Sunucuda:

```bash
cd /opt/vampir-koylu
git pull https://TOKEN@github.com/afmolla/vampir-koylu.git main
```

Daha iyisi: `git remote set-url origin` ile credential helper.

---

## C) GitHub Actions — sunucuyu uzaktan güncelle

Workflow: `.github/workflows/deploy-vps.yml` (**otomatik push yok**, sadece elle)

### Otomatik yapmak istersen (ileride)

1. Repo **Settings → Secrets → Actions** → `SSH_HOST`, `SSH_USER`, `SSH_KEY`, `DEPLOY_PATH` (`/opt/vampir-koylu` veya `C:\apps\vampir-koylu`)
2. **Actions** → **Deploy API to VPS** → **Run workflow**

Her `git push` sonrası otomatik istiyorsan bize yaz; `main` push’ta deploy’u tekrar açarız (Secrets hazır olunca).

### Sunucuda bir kez

```bash
# deploy kullanıcısı (root yerine önerilir)
adduser deploy
mkdir -p /opt/vampir-koylu
chown deploy:deploy /opt/vampir-koylu

# SSH key (Actions için) — SUNUCUDA:
sudo -u deploy ssh-keygen -t ed25519 -N "" -f /home/deploy/.ssh/github_actions
cat /home/deploy/.ssh/github_actions.pub >> /home/deploy/.ssh/authorized_keys

# Private key içeriğini kopyala (GitHub Secret'a yapıştıracaksın):
cat /home/deploy/.ssh/github_actions
```

İlk klon (deploy kullanıcısı ile):

```bash
sudo -u deploy git clone https://github.com/afmolla/vampir-koylu.git /opt/vampir-koylu
```

### GitHub repo → Settings → Secrets → Actions

| Secret | Örnek |
|--------|--------|
| `SSH_HOST` | `123.45.67.89` veya `api.senindomain.com` |
| `SSH_USER` | `deploy` |
| `SSH_KEY` | Private key tam metin (`-----BEGIN...`) |
| `SSH_PORT` | `22` (opsiyonel, yoksa 22) |
| `DEPLOY_PATH` | `/opt/vampir-koylu` |

Bundan sonra `main` branch’e her push:

1. Actions workflow çalışır  
2. SSH ile sunucuya girer  
3. `git pull` + `docker compose up -d --build`  

İzle: GitHub → **Actions** sekmesi.

---

## Akış özeti

```text
Senin PC          GitHub              Sunucu
   │                 │                    │
   │  git push       │                    │
   ├────────────────►│                    │
   │                 │  Actions SSH       │
   │                 ├───────────────────►│ git pull + docker
   │                 │                    │ API yeniden ayakta
```

---

## Mobil APK

Sunucu sadece **API** günceller. Yeni APK için ayrıca tag:

```bash
git tag v0.1.1
git push origin v0.1.1
```

→ `android-release.yml` APK üretir (Releases).

---

## Sorun giderme

| Hata | Çözüm |
|------|--------|
| `Permission denied (publickey)` | `SSH_KEY` secret, `authorized_keys` |
| `git pull` conflict | Sunucuda local değişiklik yok; `git reset --hard origin/main` (dikkat) |
| Docker build yavaş | Normal; ilk build uzun sürer |
