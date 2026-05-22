import 'package:flutter/material.dart';

import '../models/game_roles.dart';
import '../services/profile_service.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  final _api = ProfileService();
  List<dynamic> _matches = [];
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
      final data = await _api.fetchMatchHistory();
      if (mounted) setState(() => _matches = data['matches'] as List<dynamic>? ?? []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: const Text('Maç geçmişi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _matches.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(
                          child: Text(
                            'Henüz kayıtlı online maç yok.\nOnline lobide oyna.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _matches.length,
                      itemBuilder: (context, i) {
                        final m = _matches[i] as Map<String, dynamic>;
                        final won = m['won'] == true;
                        final role = m['role'] as String? ?? 'villager';
                        final meta = roleMeta(role);
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: won ? Colors.green.shade800 : Colors.grey.shade800,
                              child: Icon(
                                won ? Icons.emoji_events : Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(won ? 'Galibiyet' : 'Yenilgi'),
                            subtitle: Text(
                              '${meta.label(locale)} · Oda ${m['roomCode'] ?? '—'}\n${m['createdAt'] ?? ''}${m['mvp'] == true ? ' · MVP' : ''}',
                            ),
                            isThreeLine: true,
                            trailing: Icon(meta.icon, color: meta.color),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
