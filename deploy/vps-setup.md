# VPS kurulum rehberi (Ubuntu)

Proje: **https://github.com/afmolla/flutter**

Mobil uygulama bu sunucuya `https://api.SENIN-DOMAIN.com` ile bağlanır.

---

## Ön koşullar

| Gerekli | Örnek |
|---------|--------|
| VPS | Ubuntu 22.04 / 24.04, 2 vCPU, 2–4 GB RAM |
| Domain | `api.oyun.com` → VPS IP (A kaydı) |
| SSH | root veya sudo kullanıcı |

---

## 1) VPS’e bağlan

```bash
ssh root@SUNUCU_IP
```

---

## 2) Sistem paketleri

```bash
apt update && apt upgrade -y
apt install -y git curl ufw nginx certbot python3-certbot-nginx

# Docker (resmi kurulum — kısa yol)
apt install -y docker.io docker-compose-v2
systemctl enable docker
systemctl start docker

ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable
```

---

## 3) Projeyi klonla

```bash
cd /opt
git clone https://github.com/afmolla/flutter.git vampir-koylu
cd vampir-koylu
```

---

## 4) Production `.env` oluştur

```bash
cp deploy/env.production.example server/.env
nano server/.env
```

**Mutlaka değiştir:**

| Değişken | Ne yazacaksın |
|----------|----------------|
| `JWT_SECRET` | `openssl rand -hex 32` çıktısı |
| `DATABASE_URL` | Şifreyi `postgres` ile aynı yap (aşağıda) |
| `POSTGRES_PASSWORD` | docker compose için (adım 5) |

`DATABASE_URL` örneği (Docker içi):

```
postgresql://vampir:GÜÇLÜ_ŞİFRE@postgres:5432/vampir_koylu
```

---

## 5) Postgres şifresi (Compose)

```bash
cd /opt/vampir-koylu/deploy
export POSTGRES_PASSWORD='GÜÇLÜ_ŞİFRE'
# server/.env içindeki DATABASE_URL şifresi ile aynı olmalı
```

---

## 6) API’yi Docker ile ayağa kaldır

```bash
cd /opt/vampir-koylu/deploy
docker compose -f docker-compose.prod.yml up -d --build
```

Kontrol (sunucu içinden):

```bash
curl http://127.0.0.1:3000/health
# {"ok":true,"service":"vampir-koylu-server"}
```

---

## 7) Nginx + HTTPS

```bash
cp /opt/vampir-koylu/deploy/nginx-site.conf /etc/nginx/sites-available/vampir-koylu
nano /etc/nginx/sites-available/vampir-koylu
# server_name api.senindomain.com;  → kendi domain'in

ln -sf /etc/nginx/sites-available/vampir-koylu /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

certbot --nginx -d api.senindomain.com
```

Tarayıcıdan: `https://api.senindomain.com/health`

---

## 8) Mobil uygulamayı VPS’e bağla

APK/build alırken API adresini ver:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.senindomain.com
```

GitHub Actions için repo **Secrets** → `API_BASE_URL` eklenebilir (ileride).

---

## 9) Güncelleme (GitHub → sunucu)

**Manuel** (PC'de push ettikten sonra sunucuda):

```bash
bash /opt/vampir-koylu/deploy/scripts/vps-update.sh
```

**Otomatik:** `main`'e push → GitHub Actions SSH deploy. Kurulum: [github-deploy.md](github-deploy.md)

Yeni **zorunlu sürüm** için `server/.env` → `MIN_REQUIRED_VERSION` artır, container yeniden başlat.

---

## Sorun giderme

| Belirti | Çözüm |
|---------|--------|
| `curl 127.0.0.1:3000` çalışmıyor | `docker compose -f docker-compose.prod.yml logs api` |
| Domain açılmıyor | `nginx -t`, firewall 80/443, DNS A kaydı |
| Uygulama bağlanmıyor | HTTPS mi kullanıyorsun? HTTP değil `https://api...` |
| WebSocket kopuyor | Nginx’te `Upgrade` header’ları (nginx-site.conf’da var) |

---

## Güvenlik notları

- Postgres/Redis **dışarıya port açılmaz** (`docker-compose.prod.yml`)
- API sadece `127.0.0.1:3000` — dış dünya Nginx üzerinden girer
- `JWT_SECRET` ve DB şifresini asla GitHub’a commit etme

---

## Özet komut listesi (kopyala-yapıştır)

```bash
# 1–3: kurulum + clone (yukarıdaki gibi)
cd /opt/vampir-koylu/deploy
export POSTGRES_PASSWORD='GÜÇLÜ_ŞİFRE'
docker compose -f docker-compose.prod.yml up -d --build
curl http://127.0.0.1:3000/health
# nginx + certbot
# flutter build: API_BASE_URL=https://api.senindomain.com
```
