import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/session_store.dart';
import 'login_screen.dart';
import 'online_lobby_screen.dart';
import 'profile_hub_screen.dart';
import 'solo_game_screen.dart';
import 'splash_screen.dart';
import 'tournaments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.nick,
    this.offlineMode = false,
  });

  final String nick;
  final bool offlineMode;

  Future<void> _logout(BuildContext context) async {
    await SessionStore().clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => offlineMode ? const SplashScreen() : const LoginScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (!offlineMode)
            IconButton(
              icon: const Icon(Icons.military_tech_outlined),
              tooltip: 'Profil & görevler',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileHubScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (offlineMode) ...[
              MaterialBanner(
                content: Text(l10n.offlineModeBanner),
                leading: const Icon(Icons.wifi_off_rounded, color: Colors.amber),
                backgroundColor: Colors.amber.withValues(alpha: 0.12),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (_) => false,
                      );
                    },
                    child: Text(l10n.offlineTryOnline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              l10n.homeWelcome(nick),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _MenuButton(
              icon: Icons.smart_toy_outlined,
              label: offlineMode ? l10n.offlinePlayWithBots : l10n.soloPlay,
              subtitle: offlineMode ? l10n.offlineSoloDesc : l10n.soloPlayDesc,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SoloGameScreen(
                      nick: nick,
                      offlineMode: offlineMode,
                    ),
                  ),
                );
              },
            ),
            if (!offlineMode) ...[
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.emoji_events_outlined,
                label: 'Turnuvalar',
                subtitle: 'Coin veya ücretli katılım · ödül havuzu',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TournamentsScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.groups_2_outlined,
                label: l10n.onlinePlay,
                subtitle: l10n.onlinePlayDesc,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnlineLobbyScreen(nick: nick),
                    ),
                  );
                },
              ),
            ] else ...[
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.groups_2_outlined,
                label: l10n.onlinePlay,
                subtitle: l10n.offlineOnlineDisabled,
                enabled: false,
                onTap: () {},
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: enabled ? null : Colors.white.withValues(alpha: 0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: enabled
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.white38,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: enabled ? null : Colors.white38,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: enabled ? Colors.white70 : Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: enabled ? null : Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
