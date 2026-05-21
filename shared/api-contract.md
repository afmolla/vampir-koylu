# API sözleşmesi (özet) — v0.2.2

## GET /api/version

Query: `clientVersion`, `platform`

## GET /api/rooms

Açık lobiler: `{ "rooms": [{ "code", "playerCount", "maxPlayers", "hostNick" }] }`

## POST /api/auth/guest

Body: `{ "nick": "Ali", "locale": "tr" }`

## GET /api/auth/me

Header: `Authorization: Bearer <token>`

## WebSocket

Auth: `auth.clientVersion`, `auth.token`

| Event (client → server) | Açıklama |
|-------------------------|----------|
| `room:create` | `{ nick, maxPlayers: 6-8 }` |
| `room:join` | `{ code, nick }` |
| `room:leave` | — |
| `room:start` | Kurucu, 6+ oyuncu |
| `game:action` | `{ type: night_kill \| day_vote, targetId }` |

| Event (server → client) | Açıklama |
|-------------------------|----------|
| `room:state` | Oda/oyun durumu (oyuncuya özel rol) |

Errors: `VERSION_OUTDATED`, `UNAUTHORIZED`
