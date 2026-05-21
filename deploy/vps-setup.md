# Linux VPS kurulum rehberi

## Gereksinimler

- Ubuntu 22.04/24.04 LTS
- Domain (ör. `api.sizindomain.com`)
- 2 vCPU, 2–4 GB RAM (MVP)

## 1. Sunucu hazırlığı

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose-v2 nginx certbot python3-certbot-nginx ufw
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

## 2. Projeyi çek

```bash
git clone https://github.com/YOUR_USER/vampir-koylu.git
cd vampir-koylu
cp server/.env.example server/.env
# .env içinde JWT_SECRET, MIN_REQUIRED_VERSION, UPDATE_URL_ANDROID düzenle
```

## 3. Docker ile çalıştır

```bash
cd deploy
docker compose up -d
```

## 4. HTTPS

```bash
sudo certbot --nginx -d api.sizindomain.com
```

`deploy/nginx.conf.example` dosyasını `/etc/nginx/sites-available/` altına kopyalayıp domain’i güncelle.

## 5. Mobil uygulama

`mobile/lib/core/config.dart` içindeki `apiBaseUrl` değerini production URL ile değiştir.
