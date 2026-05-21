# api.mollayazilim.com

## DNS

- **A kaydı:** `api.mollayazilim.com` → sunucu IP (yapıldı)

## Sunucuda kontrol

```bash
curl http://api.mollayazilim.com/health
# SSL sonrası:
curl https://api.mollayazilim.com/health
```

## HTTPS (Linux + Nginx)

```bash
certbot --nginx -d api.mollayazilim.com
```

## Mobil APK

`https://api.mollayazilim.com` — tag `v0.1.1` veya üzeri Releases.

## Windows sunucu

- Firewall: 80, 443 açık
- Nginx/IIS veya Cloudflare → `127.0.0.1:3000` proxy
