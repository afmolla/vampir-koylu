# Sabah giriş — Vampir Köylü v0.2.3

## 1. Sunucuyu aç (VPS / Windows)

`C:\apps\vampir-koylu\server` (veya senin yolun):

```
start-api.cmd
```

İlk kurulumda: `npm install` (SQLite için `better-sqlite3`).

Yeşil çıktı: `MIN_REQUIRED_VERSION=0.2.3`, port **3000**.

Kontrol: http://85.95.251.204:3000/health → `{"ok":true,...}`

## 2. Telefonda APK

**Sürüm 0.2.3** yüklü olmalı.

İndir: https://github.com/afmolla/vampir-koylu/releases/tag/v0.2.3  
Direkt: https://github.com/afmolla/vampir-koylu/releases/download/v0.2.3/app-release.apk

Eski sürüm (0.2.2 ve altı) varsa önce kaldır → paket çakışması olmasın.

## 3. Güncelleme testi (opsiyonel)

Eski APK ile zorunlu güncelleme ekranını görmek için:

- `start-api-GUNCELLEME-TEST.cmd` (MIN=0.2.3)
- Telefonda 0.2.2 APK → güncelleme ekranı → otomatik indirme → 0.2.3 kur

Normal oyun için **`start-api.cmd`** kullan.

## 4. Uygulama akışı

1. Aç → splash → sürüm OK  
2. Misafir nick → giriş  
3. Ana menü:  
   - **Tek başına oyna** — botlarla  
   - **Online oyna** — lobi + **genel sohbet** (altta)  
4. Oda oluştur / katıl → **oda sohbeti** (altta)  
5. 2+ oyuncu → **Oyunu başlat** (test modu)

## Sorun

| Belirti | Çözüm |
|--------|--------|
| Bağlantı hatası | `start-api.cmd` + port 3000 |
| Güncelleme ekranı | 0.2.3 APK kur |
| Sohbet yok | Socket bağlı mı? Sunucu güncel mi? |
| Paket çakışması | Eski APK kaldır, 0.2.3 kur |
