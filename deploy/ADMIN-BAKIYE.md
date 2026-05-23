# Admin bakiye yükleme

Oyuncu profilinde **Bakiye** (TL, tam sayı) görünür. Admin API ile yükleme yapılır; işlem `balance_ledger` tablosuna yazılır.

## Ortam

`server/.env` veya `start-api.cmd`:

```
ADMIN_API_KEY=vampir-admin-change-me
```

Üretimde güçlü bir anahtar kullanın.

## Bakiye ekle

**POST** `/api/admin/balance/add`

Header: `X-Admin-Key: <ADMIN_API_KEY>`

Body (en az biri: `userId`, `nick`, `email`):

```json
{
  "nick": "OyuncuNick",
  "amount": 50,
  "note": "Havale #1234"
}
```

`amount` negatif olabilir (düzeltme); bakiye 0’ın altına inmez.

### PowerShell örneği

```powershell
$headers = @{
  "Content-Type" = "application/json"
  "X-Admin-Key"  = "vampir-admin-change-me"
}
$body = @{
  nick   = "testuser"
  amount = 100
  note   = "ilk yukleme"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://85.95.251.204:3000/api/admin/balance/add" `
  -Method POST -Headers $headers -Body $body
```

### curl

```bash
curl -X POST http://localhost:3000/api/admin/balance/add \
  -H "Content-Type: application/json" \
  -H "X-Admin-Key: vampir-admin-change-me" \
  -d '{"email":"user@mail.com","amount":25,"note":"promo"}'
```

Yanıt:

```json
{
  "ok": true,
  "nick": "testuser",
  "added": 100,
  "balance": 100
}
```

## Oyuncu tarafı

- **GET** `/api/profile/me` → `profile.balance`
- **GET** `/api/profile/balance/history` → son hareketler (JWT gerekli)

Uygulamada Profil ekranında bakiye ve son işlemler listelenir.
