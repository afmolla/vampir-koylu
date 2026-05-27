import 'package:flutter/material.dart';

import 'profile_settings_screen.dart';

/// Geriye uyumluluk — tum ayarlar [ProfileSettingsScreen] uzerinden.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.initialNick,
    this.initialAvatarUrl,
    this.offlineMode = false,
  });

  final String? initialNick;
  final String? initialAvatarUrl;
  final bool offlineMode;

  @override
  Widget build(BuildContext context) {
    return ProfileSettingsScreen(
      initialNick: initialNick,
      initialAvatarUrl: initialAvatarUrl,
      offlineMode: offlineMode,
    );
  }
}
