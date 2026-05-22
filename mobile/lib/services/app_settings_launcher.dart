import 'dart:io';

import 'package:flutter/services.dart';

/// Android: uygulama bilgisi (kaldır) ekranını açar.
class AppSettingsLauncher {
  static const _channel = MethodChannel('com.vampirkoylu.vampir_koylu/app');

  static Future<bool> openUninstallSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      await _channel.invokeMethod<void>('openAppSettings');
      return true;
    } on PlatformException {
      return false;
    }
  }
}
