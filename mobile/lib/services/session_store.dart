import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _avatarKey = 'avatar_url';
  static const _nickKey = 'nick';
  static const _localeKey = 'locale';
  static const _offlineKey = 'offline_mode';
  static const _rememberKey = 'remember_me';

  Future<void> saveSession({
    required String token,
    required String userId,
    required String nick,
    required String locale,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_nickKey, nick);
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      await prefs.setString(_avatarKey, avatarUrl);
    }
    await prefs.setString(_localeKey, locale);
    await prefs.setBool(_offlineKey, false);
  }

  /// Sunucu yokken: sadece yerel nick + botlu solo oyun.
  Future<void> saveOfflineGuest({
    required String nick,
    required String locale,
  }) async {
    final prefs = await SharedPreferences.getInstance();
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
    return prefs.getString(_tokenKey);
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
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberKey) ?? true;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_avatarKey);
    await prefs.remove(_nickKey);
    await prefs.remove(_offlineKey);
  }
}
