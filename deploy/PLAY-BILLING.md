# Google Play Billing — turnuva girişi

## Play Console

1. Uygulama → **Monetize** → Products → **In-app products**
2. Ürün ID: `tournament_entry_gold_league_premium` (sunucu: `tournament_entry_<tournamentId>`)
3. Consumable, fiyat TRY

## Uygulama akışı

1. Turnuva detay → **Play ile katıl**
2. Sunucu `iap` pending kaydı + `productId` döner
3. `in_app_purchase` satın alma
4. `POST /api/payments/play/verify` — kayıt onaylanır

Test cihazında Play hesabı **license tester** olmalı.

Ürün yoksa veya emülatörde: **Test onay** snackbar ile devam.

## Sunucu (ileride)

`GOOGLE_PLAY_SERVICE_ACCOUNT` JSON ile gerçek makbuz doğrulama (`androidpublisher` API).
