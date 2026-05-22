# GitHub `flutter` ≠ uygulama adı Vampir Köylü

| | Değer |
|---|--------|
| **GitHub repo** | [afmolla/flutter](https://github.com/afmolla/flutter) |
| **Oyun / proje** | Vampir Köylü (`vampir-koylu` klasörü içinde) |
| **VPS önerilen yol** | `C:\apps\flutter` |

Repo adı tarihsel (`flutter`); içerik vampir-koylu. **Klasör adını repoyla aynı tutmak en kolayı.**

## VPS ilk kurulum

```powershell
mkdir C:\apps -ErrorAction SilentlyContinue
cd C:\apps
git clone https://github.com/afmolla/flutter.git
cd flutter
git pull
```

## Her güncellemede (tek komut)

```powershell
cd C:\apps\flutter
git pull
.\BASLAT-API.cmd
```

veya:

```powershell
cd C:\apps\flutter\server
.\start-api.cmd
```

## Repo adını değiştirmek istersen (ileride)

GitHub → Settings → Repository name → örn. `vampir-koylu`  
Sonra VPS:

```powershell
cd C:\apps
git clone https://github.com/afmolla/vampir-koylu.git
```

`deploy\repo-paths.cmd` içinde `VPS_APP_DIR` ve URL’leri güncelle.

## Tarayıcıdan test

- http://85.95.251.204:3000/health  
- Açılmıyorsa: **Yönetici** → `deploy\FIREWALL-PORT-3000.cmd`  
- API penceresi (`start-api.cmd`) açık olmalı
