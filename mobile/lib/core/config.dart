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

  static const String clientVersion = '0.2.8';

  static const String updateTargetVersion = String.fromEnvironment(
    'UPDATE_TARGET_VERSION',
    defaultValue: '0.2.8',
  );

  static const String defaultUpdateApkUrl =
      'https://github.com/afmolla/flutter/releases/download/v0.2.8/app-release.apk';

  static const String platform = 'android';
}
