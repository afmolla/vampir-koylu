# GitHub: afmolla/vampir-koylu

| | Değer |
|---|--------|
| **GitHub repo** | [afmolla/vampir-koylu](https://github.com/afmolla/vampir-koylu) |
| **Oyun** | Vampir Köylü |
| **Bu makine (IIS)** | `C:\inetpub\wwwroot\oyun1` |
| **VPS önerilen** | `C:\apps\vampir-koylu` |

## VPS ilk kurulum

```powershell
mkdir C:\apps -ErrorAction SilentlyContinue
cd C:\apps
git clone https://github.com/afmolla/vampir-koylu.git
cd vampir-koylu
```

## Her gün API başlat

```powershell
C:\apps\vampir-koylu\BASLAT-API.cmd
```

**Bu wwwroot makinesi:**

```powershell
C:\inetpub\wwwroot\oyun1\BASLAT-API.cmd
```

`start-api.cmd`: git pull → port temizle → npm → Node.

## APK / Release

https://github.com/afmolla/vampir-koylu/releases

Örnek: `https://github.com/afmolla/vampir-koylu/releases/download/v0.2.15/app-release.apk`

## Test

- Yerel: http://127.0.0.1:3000/health
- Dış: http://85.95.251.204:3000/health
