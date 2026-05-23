/// API base URL.
///
/// **10.0.2.2** sadece Android **emülatör** içindir — PC tarayıcısında açılmaz.
/// PC'de test: http://127.0.0.1:3000/health
///
/// Gerçek telefon: aynı Wi‑Fi + bilgisayar IP:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000`
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://85.95.251.204:3000',
  );

  static const String clientVersion = '0.2.13';

  static const String updateTargetVersion = String.fromEnvironment(
    'UPDATE_TARGET_VERSION',
    defaultValue: '0.2.13',
  );

  /// Güncelleme APK — her zaman hedef sürüm (v0.2.7 yedek yok).
  static String apkUrlForVersion(String version) =>
      'https://github.com/afmolla/flutter/releases/download/v$version/app-release.apk';

  static String get defaultUpdateApkUrl => apkUrlForVersion(updateTargetVersion);

  static const String platform = 'android';

  /// Google Cloud OAuth Web client ID (sunucu dogrulama + mobil).
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
