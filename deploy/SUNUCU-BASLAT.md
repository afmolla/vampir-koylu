# Sunucuyu başlat (tek dosya)

GitHub repo: **afmolla/flutter**  
VPS klasörü: **C:\apps\flutter** (önerilen)

## Tek adım

```
C:\apps\flutter\BASLAT-API.cmd
```

veya

```
C:\apps\flutter\server\start-api.cmd
```

Script otomatik yapar:

0. `git pull origin main` (GitHub’dan son kod)  
1. Port 3000’deki eski Node’u kapatır  
2. `npm install` (gerekirse)  
3. Güncel sürüm ayarlarını yazar (`.env` + ortam)  
4. API’yi başlatır  

`git pull` atlamak için: `set SKIP_GIT_PULL=1` sonra scripti çalıştır.

## Tarayıcı test

http://85.95.251.204:3000/health → `serverBuild: "0.2.7"`

Dışarıdan açılmıyorsa: `deploy\FIREWALL-PORT-3000.cmd` (**Yönetici**)

Yollar: `deploy\REPO-VE-YOLLAR.md`
