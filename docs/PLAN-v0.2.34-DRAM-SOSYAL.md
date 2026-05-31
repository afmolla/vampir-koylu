# v0.2.34 — Dram + sosyal + Google giriş

**Tarih:** Mayıs 2026  
**Önceki:** v0.2.33 rol derinliği (gözcü, avcı, aptal, muhafız)

## Hedef

Oyuncu masada gerilim hisseder; Google ile tek tık giriş çalışır; API başlatma uyarı vermez.

## Uygulanan (bu sürüm)

| # | Özellik | Durum |
|---|---------|--------|
| G1 | `deploy/KURULUM-GOOGLE.cmd` + `google-oauth.local.cmd` | ✅ |
| G2 | `ensure-auth-secrets.cmd` — BASLAT-API otomatik birleştirme | ✅ |
| B1 | Faz geri sayım (`phaseEndsAt` gece 90s / gündüz 120s) | ✅ |
| B2 | Gece→gündüz şafak banner (mevcut) + ölümde titreşim | ✅ |
| C3 | Sohbet hızlı ifadeler (chip) | ✅ |

## Sıradaki (v0.2.35)

- Linç “son söz” mini fazı
- Ses efektleri (ölüm / sabah)
- TURN prod + ses göstergesi iyileştirme
- Host gece süresi ayarı

## Google kurulum (tek sefer)

1. `deploy\KURULUM-GOOGLE.cmd`
2. Web Client ID yapıştır → kaydet
3. `BASLAT-API.cmd`
4. Test: `/api/config/public` → `googleSignInEnabled: true`
