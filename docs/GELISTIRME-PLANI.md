# Vampir Köylü — Geliştirme planı (v0.2.31)

**Güncel sürüm:** `0.2.31`  
**API:** `http://85.95.251.204:3002`  
**Repo:** https://github.com/afmolla/vampir-koylu  

---

## v0.2.31 — Uygulandı (bu sürüm)

### Stabilite ve giriş
- [x] `wallet:update` socket + mobil AppBar anlık bakiye
- [x] `version_utils` test (latest URL gerilemesi yok)
- [x] Push token kaydı (`PushRegistration` → `/api/engagement/push-token`)
- [x] Public config: `iceServers`, `tournamentAllowBots`

### Oyun kalitesi
- [x] Doktor gece: `doctor_protect` + `canPlayerAct` / hedef listesi
- [x] Turnuva ödül: `applyTournamentRewards` maç bitince
- [x] Turnuva bot: `TOURNAMENT_ALLOW_BOTS=true` ile `fillBotsInRoom`
- [x] Profil nick: `nick_taken` l10n (`AuthFlow`)

### Sosyal ve ses
- [x] TURN env (`TURN_URL`, `TURN_USERNAME`, `TURN_CREDENTIAL`)
- [x] Arkadaş odaya davet UI (oda lobisi + `FriendsScreen`)
- [x] Deep link `vampir://join?ref=`

### Monetizasyon ve admin
- [x] Play verify: prod’da yapılandırma zorunlu, dev’de token ile onay
- [x] Gümüş+ maç coin +%5 (`applyMatchRewards`)
- [x] Admin panel coin düzeltme (`PATCH /api/admin-panel/users/:id/coins`)
- [x] Kozmetik çerçeve `UserAvatar.frameId`

---

## v0.2.32+ — Kalan (orta vadeli)

- [ ] Tam i18n (turnuva/profil/arkadaş ekranlarındaki sabit TR metinler)
- [ ] `firebase_messaging` + gerçek FCM token (şu an `android:userId` yedek)
- [ ] Google Play API tam entegrasyon (`googleapis` purchases.products.get)
- [ ] Diğer rol gece yetenekleri (dedektif, tuzak…)
- [ ] Turnuva bracket / çoklu tur
- [ ] HTTPS reverse proxy
- [ ] iOS build

---

## Sürekli kurallar

| Kural | Değer |
|-------|--------|
| Paket | `com.vampirkoylu.vampir_koylu` |
| İmza | `mobile/android/signing/release.keystore` |
| Yayın | `git tag v0.2.xx` → GitHub Actions → VPS `BASLAT-API.cmd` |

---

## VPS kontrol

1. `git pull` + `server\start-api.cmd`
2. `/health` → `0.2.31`, `googleSignInEnabled: true` (auth-secrets.env)
3. İsteğe bağlı `.env`: `TURN_URL`, `TOURNAMENT_ALLOW_BOTS`, `FCM_SERVER_KEY`

---

## Deploy

```powershell
git tag v0.2.31
git push origin main --tags
```

APK: https://github.com/afmolla/vampir-koylu/releases/download/v0.2.31/app-release.apk
