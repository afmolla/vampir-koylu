# APK oluşturma

## A) GitHub Actions (bu PC'de Android SDK gerekmez) — önerilen

### Tag ile (Releases'a yükler)

```powershell
cd c:\inetpub\wwwroot\video\vampir-koylu
git tag v0.1.0
git push origin v0.1.0
```

1–2 dk sonra: https://github.com/afmolla/flutter/releases → **app-release.apk** indir.

Sunucu IP/domain için repo **Settings → Secrets → Actions** → `API_BASE_URL` = `http://SUNUCU_IP:3000` veya `https://api.domain.com`  
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
