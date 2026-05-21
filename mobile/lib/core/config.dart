/// API base URL.
/// - Android emulator: http://10.0.2.2:3000
/// - Physical device on same LAN: http://YOUR_PC_IP:3000
/// - Production VPS: https://api.yourdomain.com
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String clientVersion = '0.1.0';
  static const String platform = 'android';
}
