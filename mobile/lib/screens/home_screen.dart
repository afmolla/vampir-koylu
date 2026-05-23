import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/engagement_service.dart';
import '../services/session_store.dart';
import '../services/socket_service.dart';
import '../services/room_session.dart';
import '../widgets/chat_popup_launcher.dart';
import '../widgets/coins_balance_chip.dart';
import '../widgets/room_communication_sheet.dart';
import '../widgets/user_avatar.dart';
import 'friends_screen.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';
import 'online_lobby_screen.dart';
import 'online_room_screen.dart';
import 'profile_hub_screen.dart';
import 'profile_settings_screen.dart';
import 'register_screen.dart';
import 'season_pass_screen.dart';
import 'solo_game_screen.dart';
import 'splash_screen.dart';
import 'tournaments_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.nick,
    this.avatarUrl,
    this.offlineMode = false,
  });

  final String nick;
  final String? avatarUrl;
  final bool offlineMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _socketService = SocketService();
  final _engagement = EngagementService();
  bool _socketReady = false;
  String? _avatarUrl;
  Map<String, dynamic>? _home;
  bool _loadingHome = true;
  bool _quickMatching = false;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.avatarUrl;
    if (!widget.offlineMode) {
      _connectSocket();
      _loadAvatar();
      _loadHome();
      _socketService.socket?.on('live:stats', _onLiveStats);
    }
  }

  void _onRoomInvite(dynamic data) {
    if (!mounted || data is! Map) return;
    final code = data['roomCode'] as String?;
    final nick = data['fromNick'] as String? ?? '?';
    if (code == null) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.inviteToRoom(nick, code)),
        action: SnackBarAction(
          label: l10n.joinRoom,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OnlineLobbyScreen(
                  nick: widget.nick,
                  socketService: _socketService,
                  joinCode: code,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onLiveStats(dynamic data) {
    if (!mounted || data is! Map) return;
    final live = _home?['live'] as Map<String, dynamic>? ?? {};
    setState(() {
      _home = {
        ...?_home,
        'live': {
          ...live,
          'onlinePlayers': data['onlinePlayers'] ?? live['onlinePlayers'],
          'openRooms': data['openRooms'] ?? live['openRooms'],
          'playersInLobbies': data['playersInLobbies'] ?? live['playersInLobbies'],
        },
      };
    });
  }

  Future<void> _loadHome() async {
    try {
      final h = await _engagement.fetchHome();
      if (mounted) setState(() => _home = h);
    } catch (_) {
      /* offline API */
    } finally {
      if (mounted) setState(() => _loadingHome = false);
    }
  }

  Future<void> _loadAvatar() async {
    final url = await SessionStore().getAvatarUrl();
    if (mounted && url != null) setState(() => _avatarUrl = url);
  }

  Future<void> _connectSocket() async {
    try {
      final token = await SessionStore().getToken();
      if (token == null || token.isEmpty) return;
      await _socketService.connect(token: token);
      _socketService.socket?.emit('chat:join', {'channel': 'general'});
      _socketService.socket?.on('room:invite', _onRoomInvite);
      if (mounted) setState(() => _socketReady = true);
    } catch (_) {
      if (mounted) setState(() => _socketReady = false);
    }
  }

  Future<void> _quickMatch() async {
    if (_quickMatching) return;
    setState(() => _quickMatching = true);
    try {
      if (!_socketReady) await _connectSocket();
      final socket = _socketService.socket;
      if (socket == null) throw Exception('Bağlantı yok');

      final completer = Completer<Map<String, dynamic>?>();
      socket.emitWithAck(
        'room:quick-match',
        {'nick': widget.nick},
        ack: (data) {
          if (data is Map && data['ok'] == true) {
            completer.complete(data['room'] as Map<String, dynamic>?);
          } else {
            completer.completeError(Exception('$data'));
          }
        },
      );
      final room = await completer.future.timeout(const Duration(seconds: 15));
      if (!mounted || room == null) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OnlineRoomScreen(
            nick: widget.nick,
            initialRoom: room,
            socketService: _socketService,
          ),
        ),
      );
      _loadHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hızlı maç: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _quickMatching = false);
    }
  }

  Future<void> _claimDaily() async {
    try {
      final r = await _engagement.claimDailyLogin();
      if (!mounted) return;
      if (r['alreadyClaimed'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bugünkü bonus zaten alındı')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '+${r['bonusCoins']} coin · seri ${r['streak']}',
            ),
          ),
        );
      }
      _loadHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
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
  void dispose() {
    _socketService.socket?.off('live:stats', _onLiveStats);
    _socketService.socket?.off('room:invite', _onRoomInvite);
    _socketService.disconnect();
    _engagement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final live = _home?['live'] as Map<String, dynamic>? ?? {};
    final daily = _home?['daily'] as Map<String, dynamic>? ?? {};
    final engagement = _home?['engagement'] as Map<String, dynamic>? ?? {};
    final profile = _home?['profile'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: UserAvatar(
            avatarUrl: _avatarUrl,
            nick: widget.nick,
            radius: 18,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
              ).then((_) {
                _loadAvatar();
                _loadHome();
              });
            },
          ),
        ),
        title: Text(l10n.appTitle),
        actions: [
          if (!widget.offlineMode)
            CoinsBalanceChip(
              coins: profile['coins'] as int? ?? 0,
              balanceTry: profile['balance'] as int? ?? 0,
            ),
          if (!widget.offlineMode) ...[
            IconButton(
              icon: const Icon(Icons.leaderboard_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.people_outline),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FriendsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.military_tech_outlined),
              tooltip: 'Profil & görevler',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileHubScreen()),
                ).then((_) => _loadHome());
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      floatingActionButton: !widget.offlineMode && _socketReady
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'home_voice',
                  onPressed: () => showRoomCommunicationSheet(
                    context: context,
                    socket: _socketService.socket,
                    nick: widget.nick,
                    title: AppLocalizations.of(context)!.generalChatTitle,
                    generalVoice: true,
                  ),
                  icon: const Icon(Icons.headset_mic),
                  label: Text(AppLocalizations.of(context)!.chatAndVoice),
                ),
                const SizedBox(height: 10),
                ChatFab(socket: _socketService.socket, nick: widget.nick),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadHome,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (widget.offlineMode) ...[
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
            if (!widget.offlineMode && engagement['showRegisterPrompt'] == true)
              Card(
                color: Colors.deepPurple.withValues(alpha: 0.2),
                child: ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.amber),
                  title: const Text('Hesabını kaydet'),
                  subtitle: const Text('Kayıt ol · hesap bonusu korunur'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                ),
              ),
            if (!widget.offlineMode) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _loadingHome
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            const Icon(Icons.sensors, color: Colors.greenAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${live['onlinePlayers'] ?? 0} oyuncu · '
                                '${live['openRooms'] ?? 0} açık oda',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (profile['balance'] != null)
                              Text(
                                '${profile['balance']} ₺',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _quickMatching ? null : _quickMatch,
                icon: _quickMatching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.flash_on),
                label: Text(_quickMatching ? 'Oda hazırlanıyor…' : 'Hızlı maç (bot ile)'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (RoomSession.hasActiveRoom) ...[
                const SizedBox(height: 8),
                Card(
                  color: const Color(0xFF1B3D2F),
                  child: ListTile(
                    leading: const Icon(Icons.meeting_room, color: Colors.greenAccent),
                    title: Text('Aktif oda: ${RoomSession.activeRoomCode}'),
                    subtitle: const Text('Oda acik — geri don veya baska islem yap'),
                    trailing: FilledButton(
                      onPressed: () {
                        if (RoomSession.lastRoomState != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OnlineRoomScreen(
                                nick: widget.nick,
                                socketService: _socketService,
                                initialRoom: RoomSession.lastRoomState!,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Odaya dön'),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Günlük & haftalık',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              daily['canClaim'] == true
                                  ? 'Günlük bonus hazır · seri ${daily['streak'] ?? 0}'
                                  : 'Günlük bonus alındı · seri ${daily['streak'] ?? 0}',
                            ),
                          ),
                          if (daily['canClaim'] == true)
                            FilledButton.tonal(
                              onPressed: _claimDaily,
                              child: const Text('Al'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SeasonPassScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Sezon pass & haftalık görevler'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              l10n.homeWelcome(widget.nick),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _MenuButton(
              icon: Icons.smart_toy_outlined,
              label: widget.offlineMode ? l10n.offlinePlayWithBots : l10n.soloPlay,
              subtitle:
                  widget.offlineMode ? l10n.offlineSoloDesc : l10n.soloPlayDesc,
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
                subtitle: 'Coin, bakiye veya ücretli katılım',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TournamentsScreen(nick: widget.nick),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.groups_2_outlined,
                label: l10n.onlinePlay,
                subtitle: 'Oda listesi · 4–8 oyuncu · bot doldur',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnlineLobbyScreen(
                        nick: widget.nick,
                        socketService: _socketService,
                      ),
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
