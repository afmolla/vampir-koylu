import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/game_roles.dart';
import '../widgets/admin_users_tab.dart';
import '../widgets/profile_sections.dart';
import '../services/engagement_service.dart';
import '../services/profile_service.dart';
import 'cosmetic_shop_screen.dart';
import 'friends_screen.dart';
import 'leaderboard_screen.dart';
import 'match_history_screen.dart';
import 'profile_settings_screen.dart';
import 'season_pass_screen.dart';
import 'tournaments_screen.dart';

class ProfileHubScreen extends StatefulWidget {
  const ProfileHubScreen({super.key});

  @override
  State<ProfileHubScreen> createState() => _ProfileHubScreenState();
}

class _ProfileHubScreenState extends State<ProfileHubScreen> {
  final _api = ProfileService();
  final _engagement = EngagementService();
  final _referralInput = TextEditingController();

  Map<String, dynamic>? _bundle;
  Map<String, dynamic>? _authUser;
  Map<String, dynamic>? _home;
  List<dynamic> _balanceHistory = [];
  List<dynamic> _recentMatches = [];
  String? _referralCode;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _referralInput.dispose();
    _api.dispose();
    _engagement.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.fetchProfile(),
        _api.fetchBalanceHistory(),
        _engagement.fetchHome(),
        _api.fetchAuthMe(),
        _api.fetchMatchHistory(limit: 5),
      ]);
      if (!mounted) return;
      final home = results[2] as Map<String, dynamic>;
      final matches = results[4] as Map<String, dynamic>;
      final auth = results[3] as Map<String, dynamic>;
      setState(() {
        _bundle = results[0] as Map<String, dynamic>;
        _balanceHistory =
            (results[1] as Map<String, dynamic>)['history'] as List<dynamic>? ??
                [];
        _home = home;
        _authUser = auth['user'] as Map<String, dynamic>?;
        _recentMatches = matches['matches'] as List<dynamic>? ?? [];
        _referralCode =
            (home['engagement'] as Map<String, dynamic>?)?['referralCode']
                as String?;
      });
    } catch (_) {
      try {
        final b = await _api.fetchProfile();
        if (mounted) setState(() => _bundle = b);
      } catch (_) {
        /* yuklenemedi */
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSettingsScreen(
          initialNick: _authUser?['nick'] as String?,
          initialAvatarUrl: _authUser?['avatarUrl'] as String?,
        ),
      ),
    );
    _load();
  }

  Future<void> _dailyLogin() async {
    final r = await _api.claimDailyLogin();
    if (!mounted) return;
    if (r['alreadyClaimed'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bugunku bonus zaten alindi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '+${r['bonusCoins']} coin, +${r['bonusXp']} XP (seri: ${r['streak']})',
          ),
        ),
      );
    }
    setState(() => _bundle = r['bundle'] as Map<String, dynamic>?);
    _load();
  }

  Future<void> _claimQuest(String id) async {
    try {
      final r = await _api.claimQuest(id);
      setState(() => _bundle = r['bundle'] as Map<String, dynamic>?);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _claimWeekly(String id) async {
    try {
      await _engagement.claimWeeklyQuest(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  String _dailyQuestTitle(String id) {
    switch (id) {
      case 'win_3':
        return '3 mac kazan';
      case 'trick_2':
        return '2 kisiyi kandir';
      case 'doctor_save':
        return 'Doktor olarak birini kurtar';
      default:
        return id;
    }
  }

  String _weeklyQuestTitle(String id) {
    switch (id) {
      case 'week_matches_5':
        return '5 mac oyna';
      case 'week_wins_3':
        return '3 galibiyet';
      case 'week_login_5':
        return '5 gun giris yap';
      default:
        return id;
    }
  }

  Widget _buildBody({
    required String locale,
    required Map<String, dynamic> profile,
    required Map<String, dynamic> stats,
    required List<dynamic> quests,
    required Map<String, dynamic>? rankProgress,
    required List<dynamic> weekly,
    required Map<String, dynamic>? season,
    required bool canClaimDaily,
  }) {
    final tier = profile['rankTier'] as String? ?? 'bronze';
    final nick = _authUser?['nick'] as String? ?? 'Oyuncu';
    final avatar = _authUser?['avatarUrl'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProfileHeroCard(
          nick: nick,
          avatarUrl: avatar,
          frameId: profile['equippedFrame'] as String?,
          rankTier: tier,
          rankLabel: rankLabel(tier, locale),
          rankPercent: (rankProgress?['percent'] as num?)?.toInt() ?? 0,
          xpToNext: rankProgress?['xpToNext'] as num? ?? 0,
          nextRankLabel: rankProgress?['nextId'] != null
              ? rankLabel(rankProgress!['nextId'] as String, locale)
              : null,
          loginStreak: profile['loginStreak'] as int? ?? 0,
          email: _authUser?['email'] as String?,
          isGuest: _authUser?['isGuest'] as bool? ?? false,
          createdAt: _authUser?['createdAt'] as String?,
          canClaimDaily: canClaimDaily,
          onAvatarTap: _openSettings,
          onClaimDaily: canClaimDaily ? _dailyLogin : null,
        ),
        const SizedBox(height: 12),
        ProfileEconomyRow(
          coins: profile['coins'] as int? ?? 0,
          balance: profile['balance'] as int? ?? 0,
          xp: profile['xp'] as int? ?? 0,
        ),
        const SizedBox(height: 16),
        const ProfileSectionTitle('Istatistikler'),
        ProfileStatsGrid(stats: stats),
        const SizedBox(height: 12),
        ProfileEquippedRow(
          profile: profile,
          onShopTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CosmeticShopScreen(bundle: _bundle),
              ),
            );
            _load();
          },
        ),
        const SizedBox(height: 8),
        ProfileSeasonMini(
          season: season,
          onOpenSeason: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SeasonPassScreen()),
            );
          },
        ),
        ProfileQuestList(
          title: 'Gunluk gorevler',
          quests: quests,
          titleForId: _dailyQuestTitle,
          onClaim: _claimQuest,
        ),
        ProfileQuestList(
          title: 'Haftalik gorevler',
          quests: weekly,
          titleForId: _weeklyQuestTitle,
          onClaim: _claimWeekly,
        ),
        ProfileRecentMatches(
          matches: _recentMatches,
          locale: locale,
          onSeeAll: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
            );
          },
        ),
        if (_referralCode != null) ...[
          const ProfileSectionTitle('Davet'),
          ProfileReferralCard(
            code: _referralCode!,
            controller: _referralInput,
            onApply: () async {
              try {
                await _engagement.applyReferral(_referralInput.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('+30 coin (davet bonusu)')),
                  );
                  _load();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            },
          ),
        ],
        if (_balanceHistory.isNotEmpty) ...[
          const ProfileSectionTitle('Bakiye hareketleri'),
          ..._balanceHistory.take(8).map((row) {
            final m = row as Map<String, dynamic>;
            final amount = m['amount'] as int? ?? 0;
            final after = m['balance_after'] as int? ?? 0;
            final note = m['note'] as String? ?? '';
            final sign = amount >= 0 ? '+' : '';
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                leading: Icon(
                  amount >= 0 ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: amount >= 0 ? Colors.greenAccent : Colors.redAccent,
                ),
                title: Text('$sign$amount ₺ · bakiye: $after ₺'),
                subtitle: note.isNotEmpty
                    ? Text(note, maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
              ),
            );
          }),
        ],
        const ProfileSectionTitle('Hizli erisim'),
        ProfileQuickActions(
          actions: [
            (icon: Icons.settings_outlined, label: 'Ayarlar', onTap: _openSettings),
            (
              icon: Icons.history,
              label: 'Mac gecmisi',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
              ),
            ),
            (
              icon: Icons.emoji_events,
              label: 'Turnuva',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TournamentsScreen(
                    nick: _authUser?['nick'] as String? ?? 'Oyuncu',
                  ),
                ),
              ),
            ),
            (
              icon: Icons.leaderboard,
              label: 'Liderlik',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              ),
            ),
            (
              icon: Icons.people_outline,
              label: 'Arkadaslar',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FriendsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Kozmetik pay-to-win degildir. Rutbe yalnizca XP ile yukselir.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilim')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final isAdmin = _bundle?['isAdmin'] == true;
    final profile = _bundle?['profile'] as Map<String, dynamic>? ?? {};
    final stats = _bundle?['stats'] as Map<String, dynamic>? ?? {};
    final quests = _bundle?['dailyQuests'] as List<dynamic>? ?? [];
    final rankProgress = _bundle?['rankProgress'] as Map<String, dynamic>?;
    final weekly = _home?['weekly'] as List<dynamic>? ?? [];
    final season = _home?['season'] as Map<String, dynamic>?;
    final daily = _home?['daily'] as Map<String, dynamic>? ?? {};
    final canClaimDaily = daily['canClaim'] == true;

    final shopAction = IconButton(
      icon: const Icon(Icons.storefront),
      tooltip: 'Kozmetik',
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CosmeticShopScreen(bundle: _bundle),
          ),
        );
        _load();
      },
    );

    final settingsAction = IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: 'Profil ve ayarlar',
      onPressed: _openSettings,
    );

    final body = RefreshIndicator(
      onRefresh: _load,
      child: _buildBody(
        locale: locale,
        profile: profile,
        stats: stats,
        quests: quests,
        rankProgress: rankProgress,
        weekly: weekly,
        season: season,
        canClaimDaily: canClaimDaily,
      ),
    );

    if (isAdmin) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profilim'),
            actions: [settingsAction, shopAction],
            bottom: TabBar(
              tabs: [
                const Tab(text: 'Profil'),
                Tab(
                  text: l10n.adminTabMembers,
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              body,
              const AdminUsersTab(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [settingsAction, shopAction],
      ),
      body: body,
    );
  }
}
