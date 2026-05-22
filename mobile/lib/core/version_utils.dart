import 'config.dart';

/// Basit semver karsilastirma (major.minor.patch).
bool isVersionOlder(String client, String latest) {
  List<int> parse(String v) {
    final parts = v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.take(3).toList();
  }

  final c = parse(client);
  final l = parse(latest);
  for (var i = 0; i < 3; i++) {
    if (c[i] < l[i]) return true;
    if (c[i] > l[i]) return false;
  }
  return false;
}

bool shouldForceUpdate({
  required String clientVersion,
  required Map<String, dynamic> versionResponse,
}) {
  if (versionResponse['needsUpdate'] == true) return true;
  if (versionResponse['allowed'] != true) return true;

  // Sunucu yanlış "0.2.0" dönse bile hedef sürüme göre zorla (0.2.4 → 0.2.5 testi).
  if (isVersionOlder(clientVersion, AppConfig.updateTargetVersion)) {
    return true;
  }

  final force = versionResponse['forceUpdate'] == true;
  if (!force) return false;

  final latest = versionResponse['latestVersion'] as String?;
  if (latest == null || latest.isEmpty) return false;

  return isVersionOlder(clientVersion, latest);
}

/// Güncelleme APK: sunucunun updateUrlAndroid (yayinli surum) oncelikli.
String resolveUpdateApkUrl(Map<String, dynamic> versionResponse) {
  final raw = (versionResponse['updateUrlAndroid'] as String? ?? '').trim();
  if (raw.isNotEmpty && raw.endsWith('.apk') && !raw.contains('/releases/latest')) {
    return raw;
  }
  final apkVer = (versionResponse['apkPublishVersion'] as String? ?? '').trim();
  if (apkVer.isNotEmpty) return AppConfig.apkUrlForVersion(apkVer);
  final latest = (versionResponse['latestVersion'] as String? ?? '').trim();
  final ver = latest.isNotEmpty ? latest : AppConfig.updateTargetVersion;
  return AppConfig.apkUrlForVersion(ver);
}

/// Indirme basarisizsa denenecek URL'ler (or. v0.2.9 henuz yok -> 0.2.8).
List<String> apkDownloadCandidates(String primary) {
  final seen = <String>{};
  final out = <String>[];
  for (final u in [
    primary,
    AppConfig.apkUrlForVersion('0.2.12'),
    AppConfig.apkUrlForVersion('0.2.11'),
    AppConfig.apkUrlForVersion('0.2.10'),
    AppConfig.apkUrlForVersion('0.2.8'),
  ]) {
    final t = u.trim();
    if (t.isEmpty || !t.endsWith('.apk') || seen.contains(t)) continue;
    seen.add(t);
    out.add(t);
  }
  return out;
}
