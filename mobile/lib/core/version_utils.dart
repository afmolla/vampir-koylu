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

/// Sunucudan gelen APK linki boş veya /latest ise doğru release URL kullan.
String resolveUpdateApkUrl(Map<String, dynamic> versionResponse) {
  final raw = (versionResponse['updateUrlAndroid'] as String? ?? '').trim();
  if (raw.isEmpty) return AppConfig.defaultUpdateApkUrl;
  if (raw.contains('/releases/latest')) return AppConfig.defaultUpdateApkUrl;
  if (!raw.endsWith('.apk')) return AppConfig.defaultUpdateApkUrl;
  return raw;
}
