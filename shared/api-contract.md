# API sözleşmesi (özet) — v0.2.3

## GET /api/version

Query: `clientVersion`, `platform`

## GET /api/rooms

Açık lobiler: `{ "rooms": [{ "code", "playerCount", "maxPlayers", "hostNick" }] }`

## GET /api/chat/:channel

Son mesajlar: `?limit=50` (max 200)

- `general` — genel lobi sohbeti
- `room:KOD` — oda içi sohbet (ör. `room:ABC123`)

Response: `{ "messages": [{ id, channel, user_id, nick, content, created_at }] }`

## POST /api/auth/guest

Body: `{ "nick": "Ali", "locale": "tr" }` — kullanıcı SQLite `users` tablosuna yazılır.

## GET /api/auth/me

Header: `Authorization: Bearer <token>`

## WebSocket

Auth: `auth.clientVersion`, `auth.token`

| Event (client → server) | Açıklama |
|-------------------------|----------|
| `room:create` | `{ nick, maxPlayers: 2-8 }` |
| `room:join` | `{ code, nick }` |
| `room:leave` | — |
| `room:start` | Kurucu, min 2 oyuncu (test) |
| `game:action` | `{ type: night_kill \| day_vote, targetId }` |
| `chat:send` | `{ channel, nick, content }` |
| `chat:join` | `{ channel }` — `general` veya `room:KOD` |

| Event (server → client) | Açıklama |
|-------------------------|----------|
| `room:state` | Oda/oyun durumu |
| `chat:message` | Yeni mesaj (DB'ye kaydedilir) |

Bağlanınca otomatik: `chat:general` odası.

Errors: `VERSION_OUTDATED`, `UNAUTHORIZED`, `invalid_message`, `not_in_room`
