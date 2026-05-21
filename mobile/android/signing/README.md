# Release imzası (APK güncellemesi)

Tüm GitHub Releases APK'ları **aynı** `release.keystore` ile imzalanır.
Böylece uygulama içinden indirilen güncellemeler «paket çakışması» vermez.

## Eski sürüm (v0.1.8 ve öncesi) yüklüyse — bir kez

Eski APK'lar farklı (debug) imza ile kurulmuş olabilir. **Bir kez:**

1. Telefondan **Vampir Köylü** uygulamasını kaldır
2. [Releases](https://github.com/afmolla/flutter/releases) üzerinden **en yeni** `app-release.apk` kur
3. Sonraki güncellemeler uygulama içinden çalışır

## Yerel build

CI ile aynı imza için `release.keystore` bu klasörde olmalı (CI cache veya repo).
`key.properties` örneği: `key.properties.example`
