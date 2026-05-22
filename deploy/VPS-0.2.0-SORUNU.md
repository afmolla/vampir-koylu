# Hâlâ 0.2.0 görünüyorsa

## Teşhis

Şu an canlı sunucu **çok eski** bir API çalıştırıyor:

```json
{"minRequiredVersion":"0.2.0","latestVersion":"0.2.0",...}
```

Ayrıca `/health` sadece `{"ok":true,"service":"vampir-koylu-server"}` dönüyorsa → **yeni kod hiç yüklenmemiş** (güncel health'te `serverBuild: 0.2.7` ve `version` bloğu olmalı).

Bu bir **mobil/APK hatası değil** — **VPS'teki Node süreci** güncellenmeli.

---

## VPS'te yap (10 dk)

### 1) Güncel kodu al

```powershell
cd C:\apps\vampir-koylu
git pull
```

(Yoksa ZIP ile `server` klasörünü komple değiştir.)

### 2) Tek komutla API başlat

**Yönetici PowerShell:**

```powershell
cd C:\apps\vampir-koylu\deploy
powershell -ExecutionPolicy Bypass -File .\VPS-API-GUNCELLE.ps1
```

Veya çift tık: `server\SUNUCU-GUNCELLEME-ACIL.cmd` (pencere açık kalsın veya NSSM ile servis).

### 3) Doğrula

Tarayıcı:

- http://85.95.251.204:3000/health  
  → `"serverBuild":"0.2.7"`, `"latestVersion":"0.2.7"`

- http://85.95.251.204:3000/api/version?clientVersion=0.2.4&platform=android  
  → `"needsUpdate":true`, `"latestVersion":"0.2.7"`

### 4) Telefon

0.2.7 APK kur veya eski sürümde uygulamayı kapat-aç (sunucu düzelince güncelleme gelir).

---

## Sık hata

| Belirti | Sebep |
|---------|--------|
| Hâlâ 0.2.0 | Eski `node` süreci port 3000'de; kill + yeniden başlat |
| Kod güncel ama API eski | Yanlış klasörden `node` çalışıyor (başka kopya) |
| `/health` database yok | Kesinlikle eski build |
