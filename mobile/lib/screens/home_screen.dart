import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/session_store.dart';
import '../services/socket_service.dart';
import '../widgets/chat_panel.dart';
import 'login_screen.dart';
import 'online_lobby_screen.dart';
import 'profile_hub_screen.dart';
import 'settings_screen.dart';
import 'solo_game_screen.dart';
import 'splash_screen.dart';
import 'tournaments_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.nick,
    this.offlineMode = false,
  });

  final String nick;
  final bool offlineMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _socketService = SocketService();
  bool _socketReady = false;

  @override
  void initState() {
    super.initState();
    if (!widget.offlineMode) _connectGeneralChat();
  }

  Future<void> _connectGeneralChat() async {
    try {
      final token = await SessionStore().getToken();
      if (token == null || token.isEmpty) return;
      await _socketService.connect(token: token);
      _socketService.socket?.emit('chat:join', {'channel': 'general'});
      if (mounted) setState(() => _socketReady = true);
    } catch (_) {
      if (mounted) setState(() => _socketReady = false);
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await SessionStore().clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            widget.offlineMode ? const SplashScreen() : const LoginScreen(),
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
          if (!widget.offlineMode) ...[
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Ayarlar',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.military_tech_outlined),
              tooltip: 'Profil & görevler',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileHubScreen()),
                );
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (widget.offlineMode) ...[
                  MaterialBanner(
                    content: Text(l10n.offlineModeBanner),
                    leading:
                        const Icon(Icons.wifi_off_rounded, color: Colors.amber),
                    backgroundColor: Colors.amber.withValues(alpha: 0.12),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const SplashScreen(),
                            ),
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
                  l10n.homeWelcome(widget.nick),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _MenuButton(
                  icon: Icons.smart_toy_outlined,
                  label: widget.offlineMode
                      ? l10n.offlinePlayWithBots
                      : l10n.soloPlay,
                  subtitle: widget.offlineMode
                      ? l10n.offlineSoloDesc
                      : l10n.soloPlayDesc,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SoloGameScreen(
                          nick: widget.nick,
                          offlineMode: widget.offlineMode,
                        ),
                      ),
                    );
                  },
                ),
                if (!widget.offlineMode) ...[
                  const SizedBox(height: 16),
                  _MenuButton(
                    icon: Icons.emoji_events_outlined,
                    label: 'Turnuvalar',
                    subtitle: 'Coin veya ücretli katılım · ödül havuzu',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TournamentsScreen(nick: widget.nick),
                        ),
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
                          builder: (_) =>
                              OnlineLobbyScreen(nick: widget.nick),
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
          if (!widget.offlineMode && _socketReady) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                l10n.chatGeneral,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            SizedBox(
              height: 180,
              child: ChatPanel(
                socket: _socketService.socket,
                channel: 'general',
                nick: widget.nick,
              ),
            ),
          ],
        ],
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
