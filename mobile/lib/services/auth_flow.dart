import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import 'local_notifications_service.dart';
import 'push_registration.dart';
import 'session_store.dart';

class AuthFlow {
  static Future<void> completeLogin(
    BuildContext context, {
    required Map<String, dynamic> data,
    required String locale,
    required bool rememberMe,
    String? loginIdentifier,
  }) async {
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final store = SessionStore();

    await store.setRememberMe(rememberMe);
    await store.saveSession(
      token: token,
      userId: user['id'] as String,
      nick: user['nick'] as String,
      locale: locale,
      avatarUrl: user['avatarUrl'] as String?,
      persist: rememberMe,
    );

    if (rememberMe) {
      final login = loginIdentifier?.trim();
      if (login != null && login.isNotEmpty) {
        await store.saveLoginIdentifier(login);
      }
    }

    await LocalNotificationsService.instance.init();
    unawaited(PushRegistration.registerAfterLogin());
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

  static String errorMessage(AppLocalizations l10n, String? code) {
    switch (code) {
      case 'email_taken':
        return l10n.errorEmailTaken;
      case 'nick_taken':
        return l10n.errorNickTaken;
      case 'nick_in_use':
        return l10n.errorNickInUse;
      case 'invalid_nick':
        return l10n.errorInvalidNick;
      case 'cannot_dm_self':
        return l10n.errorCannotDmSelf;
      case 'invalid_credentials':
        return l10n.errorInvalidCredentials;
      case 'weak_password':
        return l10n.errorWeakPassword;
      case 'google_not_configured':
        return l10n.errorGoogleNotConfigured;
      case 'facebook_not_configured':
        return l10n.errorFacebookNotConfigured;
      case 'invalid_google_token':
      case 'invalid_facebook_token':
        return l10n.errorSocialToken;
      case 'missing_token':
        return l10n.errorGoogleNoIdToken;
      default:
        return l10n.errorLoginFailed;
    }
  }

  static String? parseError(dynamic body) {
    if (body is Map) return body['error'] as String?;
    return null;
  }
}
