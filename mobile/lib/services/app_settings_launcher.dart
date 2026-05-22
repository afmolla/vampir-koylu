import 'dart:io';

import 'package:flutter/services.dart';

/// Android: kaldırma / uygulama ayarları.
class AppSettingsLauncher {
  static const _channel = MethodChannel('com.vampirkoylu.vampir_koylu/app');

  /// Sistem «Bu uygulamayı kaldır?» diyaloğu.
  static Future<bool> openUninstallDialog() async {
    if (!Platform.isAndroid) return false;
    try {
      await _channel.invokeMethod<void>('openUninstallDialog');
      return true;
    } on PlatformException {
      return false;
    }
  }

  /// Ayarlar → uygulama detayı (yedek).
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
