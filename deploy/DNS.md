# api.mollayazilim.com

| | |
|---|---|
| **Domain** | `api.mollayazilim.com` |
| **Sunucu IP** | `85.95.251.204` |
| **API (şimdilik)** | `http://85.95.251.204:3000` |
| **API (hedef)** | `https://api.mollayazilim.com` |

## Kontrol

```powershell
# API doğrudan (çalışıyor olmalı)
curl http://85.95.251.204:3000/health

# Domain (Nginx + SSL sonrası)
curl https://api.mollayazilim.com/health
```

## DNS

A kaydı: `api` → `85.95.251.204`

## Sonraki adım (domain + HTTPS)

Nginx 80/443 → `127.0.0.1:3000` proxy, sonra:

```bash
certbot --nginx -d api.mollayazilim.com
```

Windows: firewall **3000** (açık), **80/443** Nginx için aç.

## APK

- Test: `http://85.95.251.204:3000` (tag v0.1.2)
- Prod: `https://api.mollayazilim.com` (SSL sonrası v0.1.3+)
