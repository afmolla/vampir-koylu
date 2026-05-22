import 'package:flutter/material.dart';

import '../models/game_roles.dart';
import '../services/profile_service.dart';
import 'cosmetic_shop_screen.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil & Görevler')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _bundle?['profile'] as Map<String, dynamic>? ?? {};
    final quests = _bundle?['dailyQuests'] as List<dynamic>? ?? [];
    final tier = profile['rankTier'] as String? ?? 'bronze';
    final rank = kRankThemes[tier] ?? kRankThemes['bronze']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Görevler'),
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
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(rank['color'] as int),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(rank['label'] as String),
                subtitle: Text(
                  'XP ${profile['xp']} · ${profile['coins']} coin',
                ),
                trailing: FilledButton(
                  onPressed: _dailyLogin,
                  child: const Text('Günlük bonus'),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
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
              'Mağaza sadece kozmetik — pay-to-win yok.',
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
