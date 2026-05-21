# APK oluşturma

## A) GitHub Actions (bu PC'de Android SDK gerekmez) — önerilen

> **"Run failed" maili** `Deploy API to VPS` workflow'undan gelmiş olabilir — SSH secrets yokken otomatik deploy kapalı. **APK için** `Android APK Release` workflow'una bak.

### APK indir (Actions → Artifacts)

Build bitince: **Actions** → en son **Android APK Release** (yeşil) → altta **Artifacts** → `vampir-koylu-apk` → `app-release.apk`

### Tag ile (Releases)

### Tag ile (Releases'a yükler)

```powershell
cd c:\inetpub\wwwroot\video\vampir-koylu
git tag v0.1.0
git push origin v0.1.0
```

1–2 dk sonra: https://github.com/afmolla/flutter/releases → **app-release.apk** indir.

Production API: **`https://api.mollayazilim.com`** (varsayılan). Override: Secrets → `API_BASE_URL`  
Sonra yeni tag: `v0.1.1` + push.

### Elle tetikle (Actions sekmesi)

GitHub → **Actions** → **Android APK Release** → **Run workflow**  
`api_base_url` alanına sunucu adresini yaz → Artifacts'tan APK indir.

---

## B) Bu bilgisayarda (Android Studio gerekir)

`flutter doctor` → Android SDK kurulu olmalı.

```powershell
$env:Path = "C:\src\flutter\bin;" + $env:Path
powershell -ExecutionPolicy Bypass -File deploy\scripts\build-apk.ps1 -ApiUrl "http://SUNUCU_IP:3000"
```

Çıktı: `vampir-koylu-release.apk` (proje kökünde)

---

## Telefona kur

1. APK'yı indir  
2. Bilinmeyen kaynaklara izin ver  
3. Kur → aç  

Sunucu hazır değilse girişte ağ hatası normal; sunucu + doğru `API_BASE_URL` ile APK'yı yeniden build et.
