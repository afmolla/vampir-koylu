import 'package:flutter/material.dart';

import '../services/engagement_service.dart';

class SeasonPassScreen extends StatefulWidget {
  const SeasonPassScreen({super.key});

  @override
  State<SeasonPassScreen> createState() => _SeasonPassScreenState();
}

class _SeasonPassScreenState extends State<SeasonPassScreen> {
  final _api = EngagementService();
  Map<String, dynamic>? _season;
  List<dynamic> _weekly = [];
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
      final home = await _api.fetchHome();
      if (mounted) {
        setState(() {
          _season = home['season'] as Map<String, dynamic>?;
          _weekly = home['weekly'] as List<dynamic>? ?? [];
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _claimWeekly(String id) async {
    try {
      await _api.claimWeeklyQuest(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _claimSeason(int tier, String track) async {
    try {
      await _api.claimSeasonTier(tier, track: track);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiers = _season?['tiers'] as List<dynamic>? ?? [];
    final seasonXp = _season?['seasonXp'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Sezon & haftalık')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Sezon XP: $seasonXp',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Haftalık görevler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ..._weekly.map((q) {
                    final m = q as Map<String, dynamic>;
                    final progress = m['progress'] as int? ?? 0;
                    final goal = m['goal'] as int? ?? 1;
                    final done = progress >= goal;
                    return Card(
                      child: ListTile(
                        title: Text(m['id'] as String? ?? ''),
                        subtitle: Text('$progress / $goal'),
                        trailing: done && m['claimed'] != true
                            ? FilledButton(
                                onPressed: () =>
                                    _claimWeekly(m['id'] as String),
                                child: const Text('Al'),
                              )
                            : Text(m['claimed'] == true ? '✓' : ''),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  const Text(
                    'Sezon pass',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...tiers.map((t) {
                    final m = t as Map<String, dynamic>;
                    final tier = m['tier'] as int? ?? 0;
                    final unlocked = m['unlocked'] == true;
                    return Card(
                      child: ListTile(
                        title: Text('Seviye $tier'),
                        subtitle: Text(
                          unlocked ? 'Açık' : '${m['xp']} XP gerekli',
                        ),
                        trailing: unlocked
                            ? Wrap(
                                spacing: 4,
                                children: [
                                  if (m['freeClaimed'] != true)
                                    TextButton(
                                      onPressed: () => _claimSeason(tier, 'free'),
                                      child: const Text('Ücretsiz'),
                                    ),
                                  if (m['premiumClaimed'] != true)
                                    TextButton(
                                      onPressed: () =>
                                          _claimSeason(tier, 'premium'),
                                      child: const Text('Premium'),
                                    ),
                                ],
                              )
                            : null,
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
