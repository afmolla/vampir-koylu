# Sabah giriş — Vampir Köylü v0.2.2

## 1. Sunucuyu aç (VPS / Windows)

`C:\apps\vampir-koylu\server` (veya senin yolun):

```
start-api.cmd
```

Yeşil çıktı: `MIN_REQUIRED_VERSION=0.2.2`, port **3000**.

Kontrol (PC veya telefon tarayıcısı):

- http://85.95.251.204:3000/health → `{"ok":true,...}`

## 2. Telefonda APK

**Sürüm 0.2.2** yüklü olmalı (eski 0.1.x ile paket çakışması olur → önce kaldır).

İndir: https://github.com/afmolla/flutter/releases  

**Aktif sürümler (sadece bunlar):** `v0.1.8`, `v0.1.9`, `v0.2.2` — güncel olan **v0.2.2**

APK yoksa: GitHub → **Actions** → **Android APK Release** → **Run workflow** → tag: `v0.1.9` veya `v0.2.2`  
Dosya: **app-release.apk**

## 3. Uygulama akışı

1. Aç → splash → sürüm OK  
2. Misafir nick → giriş  
3. Ana menü:  
   - **Tek başına oyna** — 6 kişi, botlarla (sunucu gerekmez, sadece giriş için API)  
   - **Online oyna** — oda oluştur / koda katıl (6+ oyuncu ile başlar)

## 4. Online test (2+ telefon)

1. Her telefonda 0.2.2 APK + misafir giriş  
2. Birinde **Oda oluştur** → kodu diğerine ver  
3. 6 kişi dolunca kurucu **Oyunu başlat**

## Sorun

| Belirti | Çözüm |
|--------|--------|
| Bağlantı hatası | Sunucu `start-api.cmd` çalışıyor mu? |
| Güncelleme ekranı | 0.2.2 APK kur; `start-api.cmd` kullan (test cmd değil) |
| Paket çakışması | Eski APK’yı kaldır, 0.2.2 kur |
| Online 6 kişi yok | Solo mod veya daha fazla cihaz |

İyi oyunlar.
