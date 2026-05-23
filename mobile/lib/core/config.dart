import 'server_config.dart';

/// API base URL.
///
/// **10.0.2.2** sadece Android **emülatör** içindir — PC tarayıcısında açılmaz.
/// PC'de test: http://127.0.0.1:3002/health
///
/// Gerçek telefon / VPS: `flutter run --dart-define=API_BASE_URL=http://85.95.251.204:3002`
class AppConfig {
  /// APK derlemede gömülür; çalışırken [ServerConfig.effectiveBaseUrl] kullan.
  static const String defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://85.95.251.204:3002',
  );

  static String get apiBaseUrl => ServerConfig.effectiveBaseUrl;

  static const String clientVersion = '0.2.25';

  static const String updateTargetVersion = String.fromEnvironment(
    'UPDATE_TARGET_VERSION',
    defaultValue: '0.2.25',
  );

  /// Yayınlanmış APK'lar şimdilik eski repoda; yeni repoya taşınınca primary yeterli olur.
  static const String apkReleaseRepoPrimary = 'afmolla/vampir-koylu';
  static const String apkReleaseRepoLegacy = 'afmolla/flutter';

  static String apkUrlForVersion(String version, {bool legacy = false}) {
    final repo = legacy ? apkReleaseRepoLegacy : apkReleaseRepoPrimary;
    return 'https://github.com/$repo/releases/download/v$version/app-release.apk';
  }

  /// Önce yeni repo, sonra eski (404 önleme).
  static List<String> apkUrlsForVersion(String version) => [
        apkUrlForVersion(version),
        apkUrlForVersion(version, legacy: true),
      ];

  static String get defaultUpdateApkUrl => apkUrlForVersion(updateTargetVersion);

  /// GitHub Releases "latest" — tag degisse bile en son APK.
  static String get apkLatestDownloadUrl =>
      'https://github.com/$apkReleaseRepoPrimary/releases/latest/download/app-release.apk';

  static const String platform = 'android';

  /// Google Cloud OAuth Web client ID (sunucu dogrulama + mobil).
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
