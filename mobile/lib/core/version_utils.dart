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

/// Sunucunun bildirdigi hedef surum (APK yayin).
String resolveTargetVersion(Map<String, dynamic> versionResponse) {
  final publish =
      (versionResponse['apkPublishVersion'] as String? ?? '').trim();
  if (publish.isNotEmpty) return publish;
  final latest = (versionResponse['latestVersion'] as String? ?? '').trim();
  if (latest.isNotEmpty) return latest;
  return AppConfig.updateTargetVersion;
}

bool shouldForceUpdate({
  required String clientVersion,
  required Map<String, dynamic> versionResponse,
}) {
  if (versionResponse['needsUpdate'] == true) return true;
  if (versionResponse['allowed'] != true) return true;

  final target = resolveTargetVersion(versionResponse);
  if (target.isNotEmpty && isVersionOlder(clientVersion, target)) {
    return true;
  }

  final force = versionResponse['forceUpdate'] == true;
  if (!force) return false;

  final latest = versionResponse['latestVersion'] as String?;
  if (latest == null || latest.isEmpty) return false;

  return isVersionOlder(clientVersion, latest);
}

String? versionFromApkUrl(String url) {
  final m = RegExp(
    r'/releases/download/v([^/]+)/app-release\.apk',
  ).firstMatch(url);
  return m?.group(1);
}

/// Guncelleme APK — her zaman en guncel yayin surumune gider (eski 0.2.16 degil).
String resolveUpdateApkUrl(Map<String, dynamic> versionResponse) {
  final targetVer = resolveTargetVersion(versionResponse);
  final canonical = AppConfig.apkUrlForVersion(targetVer);

  final latestUrl =
      (versionResponse['updateUrlLatest'] as String? ?? '').trim();
  if (latestUrl.isNotEmpty && latestUrl.endsWith('.apk')) {
    return latestUrl;
  }

  final raw = (versionResponse['updateUrlAndroid'] as String? ?? '').trim();
  if (raw.isNotEmpty && raw.endsWith('.apk')) {
    final urlVer = versionFromApkUrl(raw);
    if (urlVer == null || !isVersionOlder(urlVer, targetVer)) {
      return raw;
    }
  }

  return canonical;
}

/// Indirme denemeleri: sadece hedef surum ve ustu (eski surumlere dusme yok).
List<String> apkDownloadCandidates(
  String primary, {
  Map<String, dynamic>? versionResponse,
}) {
  final seen = <String>{};
  final out = <String>[];

  void addUrl(String u) {
    final t = u.trim();
    if (t.isEmpty || !t.endsWith('.apk') || seen.contains(t)) return;
    seen.add(t);
    out.add(t);
  }

  final versions = <String>[];
  void addVer(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty || versions.contains(t)) return;
    versions.add(t);
  }

  if (versionResponse != null) {
    addVer(versionResponse['apkPublishVersion'] as String?);
    addVer(versionResponse['latestVersion'] as String?);
  }
  addVer(versionFromApkUrl(primary));
  addVer(AppConfig.updateTargetVersion);

  versions.sort((a, b) => isVersionOlder(a, b) ? 1 : -1);

  for (final ver in versions) {
    for (final u in AppConfig.apkUrlsForVersion(ver)) {
      addUrl(u);
    }
  }

  addUrl(AppConfig.apkLatestDownloadUrl);
  addUrl(primary);

  return out;
}
