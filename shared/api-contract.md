# API sözleşmesi (özet)

## GET /api/version

Query: `clientVersion`, `platform`

Response:

```json
{
  "minRequiredVersion": "0.1.0",
  "latestVersion": "0.1.0",
  "forceUpdate": true,
  "allowed": true,
  "updateUrlAndroid": "https://github.com/.../releases/latest",
  "message": null,
  "platform": "android"
}
```

## POST /api/auth/guest

Body: `{ "nick": "Ali", "locale": "tr" }`

Response: `{ "token": "...", "user": { "id", "nick", "isGuest", "locale" } }`

## WebSocket

Auth handshake: `auth.clientVersion`, `auth.token`

Errors: `VERSION_OUTDATED`, `UNAUTHORIZED`
