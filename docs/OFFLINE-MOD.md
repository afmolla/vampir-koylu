# Çevrimdışı mod (v0.2.8)

Sunucuya (`API_BASE_URL`) ulaşılamazsa açılış ekranında **Internetsiz devam et** görünür.

## Akış

1. Splash → sunucu kontrolü başarısız
2. **Internetsiz devam et** → takma ad → ana menü (çevrimdışı)
3. **Botlarla oyna** → mevcut `SoloGame` (sen + 5 bot, tam gece/gündüz döngüsü)
4. Çevrimiçi oyun kapalı; banner’dan **Sunucuya bağlan** ile splash’a dönülür

Giriş ekranında da **Internetsiz devam et** ve ağ hatasında SnackBar kısayolu vardır.

## Teknik

- `SessionStore.saveOfflineGuest` — token yok, `offline_mode=true`
- `HomeScreen(offlineMode: true)` — sadece solo + devre dışı online kartı
