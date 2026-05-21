# GitHub repo oluşturma

Bu makinede `gh` oturumu açık değil. Aşağıdaki adımları bir kez çalıştır:

## 1. GitHub CLI giriş

```powershell
gh auth login
```

(Browser veya token ile giriş)

## 2. Repo oluştur ve push

```powershell
cd c:\inetpub\wwwroot\video\vampir-koylu
gh repo create vampir-koylu --public --source=. --remote=origin --push
```

Farklı isim istersen `vampir-koylu` yerine kendi adını yaz.

## 3. Sunucu .env güncelle

`server/.env` içinde:

```
UPDATE_URL_ANDROID=https://github.com/KULLANICI_ADIN/vampir-koylu/releases/latest
```

## 4. İlk APK release

```powershell
git tag v0.1.0
git push origin v0.1.0
```

GitHub Actions APK’yı Releases’a yükler.
