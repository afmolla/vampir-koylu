import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import 'session_store.dart';

class AuthFlow {
  static Future<void> completeLogin(
    BuildContext context, {
    required Map<String, dynamic> data,
    required String locale,
    required bool rememberMe,
  }) async {
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    await SessionStore().setRememberMe(rememberMe);
    await SessionStore().saveSession(
      token: token,
      userId: user['id'] as String,
      nick: user['nick'] as String,
      locale: locale,
      avatarUrl: user['avatarUrl'] as String?,
    );
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          nick: user['nick'] as String,
          avatarUrl: user['avatarUrl'] as String?,
        ),
      ),
    );
  }

  static String errorMessage(String? code) {
    switch (code) {
      case 'email_taken':
        return 'Bu e-posta zaten kayıtlı.';
      case 'invalid_credentials':
        return 'E-posta veya şifre hatalı.';
      case 'weak_password':
        return 'Şifre en az 6 karakter olmalı.';
      case 'google_not_configured':
        return 'Google giriş sunucuda yapılandırılmamış (GOOGLE_CLIENT_ID).';
      case 'facebook_not_configured':
        return 'Facebook giriş sunucuda yapılandırılmamış.';
      case 'invalid_google_token':
      case 'invalid_facebook_token':
        return 'Sosyal giriş doğrulanamadı.';
      default:
        return 'Giriş başarısız.';
    }
  }

  static String? parseError(dynamic body) {
    if (body is Map) return body['error'] as String?;
    return null;
  }
}
