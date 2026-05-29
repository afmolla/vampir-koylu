# Telefon sunucuya ulaşamıyor — kontrol listesi

## Sık görülen neden

| Nerede API çalışıyor? | Telefon neye bakıyor? | Sonuç |
|----------------------|------------------------|--------|
| Sadece **bu PC** (`127.0.0.1:3002`) | VPS `85.95.251.204:3000` | Bağlantı hatası |
| VPS’te API **kapalı** | `85.95.251.204:3002` | Zaman aşımı |
| VPS **3000** = Next.js | APK `…:3000/health` | 404 — oyun API’si değil |

`GET /health` → `{"ok":true,"service":"vampir-koylu-server"}` dönmeli.

## VPS (85.95.251.204) — production

1. RDP ile VPS’e gir.
2. `C:\apps\vampir-koylu\BASLAT-API.cmd` veya `C:\inetpub\wwwroot\oyun1\BASLAT-API.cmd`
3. `deploy\repo-paths.cmd` → `API_PORT=3002`
4. **Yönetici** CMD: `deploy\FIREWALL-PORT-3000.cmd` (port 3002 açar)
5. Test: http://85.95.251.204:3002/health

APK içindeki adres: `http://85.95.251.204:3002` (v0.2.15 eski build’de **3000** olabilir → yeni APK gerekir).

## Aynı Wi‑Fi’de test (PC’de API açıkken)

- PC IP: `ipconfig` → örn. `192.168.1.105`
- Telefonda tarayıcı: http://192.168.1.105:3002/health
- APK’yı bu IP ile yeniden derle:  
  `flutter build apk --dart-define=API_BASE_URL=http://192.168.1.105:3002`

## Bu PC dışarıdan

Bu makinenin internet IP’si **85.95.251.204 değil** (farklıysa telefon VPS’e gider, PC’ye değil).
