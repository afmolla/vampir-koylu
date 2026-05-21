# GitHub — afmolla/flutter

Repo: https://github.com/afmolla/flutter

## 1. GitHub CLI giriş (bir kez)

```powershell
gh auth login
```

## 2. Push

```powershell
cd c:\inetpub\wwwroot\video\vampir-koylu
git branch -M main
git push -u origin main
```

Remote zaten ayarlı: `origin` → `https://github.com/afmolla/flutter.git`

## 3. İlk APK (GitHub Releases)

```powershell
git tag v0.1.0
git push origin v0.1.0
```

Actions sekmesinden build’i izle; APK **Releases** altında görünür.

## 4. Sunucu

`server/.env`:

```
UPDATE_URL_ANDROID=https://github.com/afmolla/flutter/releases/latest
```
