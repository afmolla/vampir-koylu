# Flutter SDK (bu bilgisayar)

SDK kuruldu: `C:\src\flutter`

## Kalıcı PATH (PowerShell — yönetici)

```powershell
[Environment]::SetEnvironmentVariable(
  "Path",
  $env:Path + ";C:\src\flutter\bin",
  "User"
)
```

Yeni terminal aç, sonra:

```powershell
flutter doctor
```

Android lisansları:

```powershell
flutter doctor --android-licenses
```
