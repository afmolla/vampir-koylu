import 'package:flutter/material.dart';

import '../widgets/rank_progress_card.dart';
import '../services/profile_service.dart';
import 'cosmetic_shop_screen.dart';
import 'match_history_screen.dart';
import 'tournaments_screen.dart';

class ProfileHubScreen extends StatefulWidget {
  const ProfileHubScreen({super.key});

  @override
  State<ProfileHubScreen> createState() => _ProfileHubScreenState();
}

class _ProfileHubScreenState extends State<ProfileHubScreen> {
  final _api = ProfileService();
  Map<String, dynamic>? _bundle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final b = await _api.fetchProfile();
      if (mounted) setState(() => _bundle = b);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _dailyLogin() async {
    final r = await _api.claimDailyLogin();
    if (!mounted) return;
    if (r['alreadyClaimed'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bugünkü bonus zaten alındı')),
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

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _bundle?['profile'] as Map<String, dynamic>? ?? {};
    final stats = _bundle?['stats'] as Map<String, dynamic>? ?? {};
    final quests = _bundle?['dailyQuests'] as List<dynamic>? ?? [];
    final rankProgress = _bundle?['rankProgress'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CosmeticShopScreen(bundle: _bundle),
                ),
              );
              _load();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RankProgressCard(
              profile: profile,
              rankProgress: rankProgress,
              locale: locale,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'Maç',
                    value: '${stats['totalMatches'] ?? 0}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    label: 'Galibiyet',
                    value: '${stats['wins'] ?? 0}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    label: 'Oran',
                    value: '%${stats['winRate'] ?? 0}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _dailyLogin,
              child: const Text('Günlük bonus al'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Maç geçmişi'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TournamentsScreen()),
                      );
                    },
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('Turnuvalar'),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                'Günlük görevler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...quests.map((q) {
              final m = q as Map<String, dynamic>;
              final progress = m['progress'] as int? ?? 0;
              final goal = m['goal'] as int? ?? 1;
              final done = progress >= goal;
              return Card(
                child: ListTile(
                  title: Text(_questTitle(m['id'] as String? ?? '')),
                  subtitle: Text('$progress / $goal'),
                  trailing: done && m['claimed'] != true
                      ? FilledButton(
                          onPressed: () => _claimQuest(m['id'] as String),
                          child: const Text('Al'),
                        )
                      : Text(m['claimed'] == true ? '✓' : ''),
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text(
              'Rütbe: Bronz → Gümüş → Altın → Platin → Elmas → Ölümsüz. Kozmetik pay-to-win değil.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _questTitle(String id) {
    switch (id) {
      case 'win_3':
        return '3 maç kazan';
      case 'trick_2':
        return '2 kişiyi kandır';
      case 'doctor_save':
        return 'Doktor olarak birini kurtar';
      default:
        return id;
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
