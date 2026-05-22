import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import 'tournament_detail_screen.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  final _api = ProfileService();
  List<dynamic> _list = [];
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
      final data = await _api.fetchTournaments();
      if (mounted) setState(() => _list = data['tournaments'] as List<dynamic>? ?? []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Turnuvalar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Coin veya ücretli katılım. Ödül havuzu kayıtlarla büyür.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ..._list.map((raw) {
                    final t = raw as Map<String, dynamic>;
                    final registered = t['registered'] == true;
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.emoji_events,
                          color: registered ? Colors.amber : Colors.white54,
                          size: 36,
                        ),
                        title: Text(t['title'] as String? ?? ''),
                        subtitle: Text(
                          '${t['entryCount']}/${t['maxPlayers']} oyuncu · Havuz ${t['prizePoolCoins']} coin\n'
                          'Giriş: ${t['entryFeeCoins']} coin'
                          '${t['entryFeeTry'] != null ? ' veya ${t['entryFeeTry']} ₺' : ''}',
                        ),
                        isThreeLine: true,
                        trailing: registered
                            ? const Chip(label: Text('Kayıtlı'))
                            : const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TournamentDetailScreen(
                                tournamentId: t['id'] as String,
                              ),
                            ),
                          );
                          _load();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
