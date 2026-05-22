# Release imzası (APK güncellemesi)

Tüm GitHub Releases APK'ları **aynı** `release.pfx` ile imzalanır (`key.properties` + Gradle).
Böylece uygulama içinden indirilen güncellemeler «paket çakışması» vermez.

## Eski sürüm (0.2.7 ve öncesi, farklı imza) — bir kez

Eski APK'lar CI'da her seferinde farklı **debug** imza ile üretilmiş olabilir. **Bir kez:**

1. Güncelleme ekranında **«Uygulamayı kaldır»** → Ayarlarda **Kaldır**
2. **«İndir ve yükle»** ile **v0.2.8** kur
3. Sonraki güncellemeler üstüne kurulur (çakışma olmaz)

## Yerel build

`mobile/android/key.properties` ve `signing/release.pfx` repoda (sabit imza).

Yeniden üretmek (Windows):

```powershell
$cert = New-SelfSignedCertificate -Type Custom -Subject "CN=Vampir Koylu" -KeyAlgorithm RSA -KeyLength 2048 -CertStoreLocation Cert:\CurrentUser\My -NotAfter (Get-Date).AddYears(30)
$pwd = ConvertTo-SecureString "vampir_koylu_store" -AsPlainText -Force
Export-PfxCertificate -Cert $cert -FilePath signing\release.pfx -Password $pwd
```

Sonra `key.properties` içindeki şifrelerle aynı olmalı.
