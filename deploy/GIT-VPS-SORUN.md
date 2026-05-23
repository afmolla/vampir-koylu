# Git “hatalı” — VPS düzeltme

## Belirti

- `BASLAT-API.cmd` → `git pull` hata
- `Your branch and 'origin/main' have diverged`
- `Please commit your changes or stash them`
- Eski kod çalışıyor (sunucu 0.2.0 / güncelleme yok)

## Hızlı çözüm (VPS, Yönetici CMD)

```cmd
cd C:\apps\vampir-koylu
deploy\VPS-GIT-DUZELT.cmd
```

veya elle:

```cmd
cd C:\apps\vampir-koylu
git fetch origin
git reset --hard origin/main
git clean -fd -e server/data -e server/.env
BASLAT-API.cmd
```

`server/data` ve `.env` silinmez (SQLite + ayarlar kalır).

## İlk kurulum (clone yoksa)

```cmd
mkdir C:\apps
cd C:\apps
git clone https://github.com/afmolla/vampir-koylu.git
cd flutter
BASLAT-API.cmd
```

## Yerel PC (inetpub)

Bu klasörde `git status` temiz olmalı. Tag uyarısı (dangling) zararsız; isteğe bağlı:

```cmd
git fetch origin --prune --prune-tags
```

## GitHub tag / APK

`v0.2.9` tag’i birkaç kez force-push edildiyse Actions yeniden çalıştır:

Actions → **Android APK Release** → Run workflow → `v0.2.9`

APK yoksa sunucu `APK_PUBLISH_VERSION=0.2.8` kullanır (`start-api.cmd`).
