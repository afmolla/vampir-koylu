# Plan: Turnuva, Ödeme, Rütbe & Maç Geçmişi

## Mevcut durum

| Özellik | Durum |
|---------|--------|
| Rütbe (bronz/gümüş/altın/ölümsüz) | XP ile hesaplanıyor; DB `rank_tier` senkron değil |
| Maç geçmişi | DB’ye yazılıyor, listede gösterilmiyor |
| Kozmetik mağaza | Satın alma var, kuşanma API var / UI eksik |
| Turnuva | Yok |
| Gerçek ödeme (IAP/kart) | Yok, sadece coin |

---

## Hedef ürün

1. **Anlamlı rütbe merdiveni** — Bronz → Gümüş → Altın → Platin → Elmas → Ölümsüz Vampir  
2. **Maç geçmişi** — Kazanç/kayıp, rol, MVP, tarih  
3. **Turnuvalar** — Kayıt, coin veya ücretli katılım, ödül havuzu  
4. **Ödeme** — Önce coin; Play Billing için altyapı (pending → onay)

---

## Faz 1 — Rütbe & geçmiş (bu sprint)

**Sunucu**

- `RANKS` genişletme + `rankProgress` (sonraki seviye XP)
- Her XP güncellemesinde `rank_tier` yaz
- `GET /api/profile/matches` — son 50 maç
- `GET /api/profile/stats` — toplam maç, galibiyet, oran

**Mobil**

- Profil hub yenileme: rütbe kartı, ilerleme çubuğu, istatistik şeridi
- `MatchHistoryScreen` — liste + detay özeti
- `kRankThemes` TR etiketleri (Bronz Köylü, Gümüş Avcı, …)

---

## Faz 2 — Turnuva çekirdeği (bu sprint)

**Sunucu**

- Tablolar: `tournaments`, `tournament_entries`
- Durumlar: `registration` → `live` → `finished`
- `GET /api/tournaments` — açık turnuvalar
- `POST /api/tournaments/:id/register` — `{ method: "coins" | "iap" }`
- Coin: anında kesinti + kayıt
- IAP: `payment_status=pending` + `productId` dön (mobilde “Yakında” / test onayı)
- Demo turnuva seed (haftalık köylü kupası)

**Mobil**

- `TournamentsScreen` — liste
- `TournamentDetailScreen` — ödül, ücret, kayıt butonları
- Ana menüde **Turnuvalar**

---

## Faz 3 — Ödeme & turnuva oyunu (sonraki sprint)

- Google Play Billing entegrasyonu
- `POST /api/payments/verify` — makbuz doğrulama
- Turnuva lobisi: dolunca oda aç, bracket basit
- Ödül dağıtımı (coin + kozmetik kupa)

---

## Faz 4 — Sosyal & kozmetik (sonraki sprint)

- Sezonluk leaderboard
- Kuşanma UI + oyunda frame/skin
- Turnuva rozetleri

---

## Rütbe tablosu (Faz 1)

| ID | TR ad | Min XP | Avantaj (gösterim) |
|----|--------|--------|---------------------|
| bronze | Bronz Köylü | 0 | Temel |
| silver | Gümüş Avcı | 300 | +5% maç coin |
| gold | Altın Stratej | 1 000 | Turnuvaya katılım |
| platinum | Platin Usta | 2 500 | Turnuva ücreti −10% |
| diamond | Elmas Efsane | 4 500 | Özel çerçeve |
| immortal_vampire | Ölümsüz Vampir | 8 000 | Efsane rozeti |

---

## Turnuva örnek ekonomi

| Alan | Örnek |
|------|--------|
| Giriş (coin) | 50–200 coin |
| Giriş (TL) | 29,99 ₺ (IAP, Faz 3) |
| Ödül havuzu | Girişlerin %80’i + sponsor coin |
| Min oyuncu | 6 |
| Max oyuncu | 32 |

---

## Uygulama sırası (bugün)

1. ✅ Bu plan dosyası  
2. Sunucu: DB + progression + tournaments + profile routes  
3. Mobil: profil, geçmiş, turnuva ekranları  
4. Sürüm `0.2.9` + VPS `BASLAT-API.cmd`
