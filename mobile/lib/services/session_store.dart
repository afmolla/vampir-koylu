import 'package:shared_preferences/shared_preferences.dart';

/// Oturum: [persist]=true iken token diskte kalir (beni hatirla).
class SessionStore {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _avatarKey = 'avatar_url';
  static const _nickKey = 'nick';
  static const _localeKey = 'locale';
  static const _offlineKey = 'offline_mode';
  static const _rememberKey = 'remember_me';
  static const _loginKey = 'saved_login';

  /// Beni hatirla kapali oturum — uygulama acikken API icin.
  static String? _memoryToken;

  Future<void> saveSession({
    required String token,
    required String userId,
    required String nick,
    required String locale,
    String? avatarUrl,
    bool persist = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (persist) {
      await prefs.setString(_tokenKey, token);
      _memoryToken = null;
    } else {
      _memoryToken = token;
      await prefs.remove(_tokenKey);
    }
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_nickKey, nick);
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      await prefs.setString(_avatarKey, avatarUrl);
    }
    await prefs.setString(_localeKey, locale);
    await prefs.setBool(_offlineKey, false);
  }

  Future<void> saveLoginIdentifier(String login) async {
    final trimmed = login.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginKey, trimmed);
  }

  Future<String?> getLoginIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginKey);
  }

  /// Beni hatirla kapatilinca veya cikista kalici oturumu sil.
  Future<void> clearPersistedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _memoryToken = null;
    await prefs.remove(_tokenKey);
    await prefs.remove(_loginKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_avatarKey);
  }

  Future<void> saveOfflineGuest({
    required String nick,
    required String locale,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _memoryToken = null;
    await prefs.remove(_tokenKey);
    await prefs.setString(_nickKey, nick);
    await prefs.setString(_localeKey, locale);
    await prefs.setBool(_offlineKey, true);
  }

  Future<bool> isOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineKey) ?? false;
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<void> setAvatarUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, url);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final disk = prefs.getString(_tokenKey);
    if (disk != null && disk.isNotEmpty) return disk;
    return _memoryToken;
  }

  Future<bool> hasPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_tokenKey);
    return t != null && t.isNotEmpty;
  }

  Future<String?> getAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarKey);
  }

  Future<String?> getNick() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nickKey);
  }

  Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'tr';
  }

  Future<void> setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
  }

  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, value);
    if (!value) {
      await clearPersistedCredentials();
    }
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberKey) ?? true;
  }

  Future<void> clear() async {
    _memoryToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_avatarKey);
    await prefs.remove(_nickKey);
    await prefs.remove(_offlineKey);
    await prefs.remove(_loginKey);
  }
}
