import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../services/session_store.dart';
import 'tournament_lobby_screen.dart';

class TournamentDetailScreen extends StatefulWidget {
  const TournamentDetailScreen({
    super.key,
    required this.tournamentId,
    this.nick,
  });

  final String tournamentId;
  final String? nick;

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  final _api = ProfileService();
  Map<String, dynamic>? _t;
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
      final t = await _api.fetchTournament(widget.tournamentId);
      if (mounted) setState(() => _t = t);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registerCoins() async {
    try {
      final r = await _api.registerTournament(widget.tournamentId, method: 'coins');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt tamam! ${r['paidCoins']} coin ödendi.')),
      );
      setState(() => _t = r['tournament'] as Map<String, dynamic>?);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _registerIap() async {
    try {
      final r = await _api.registerTournament(widget.tournamentId, method: 'iap');
      if (!mounted) return;
      final ref = r['paymentRef'] as String?;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ödeme bekliyor (${r['amountTry']} ₺). Play Billing yakında. Test için onayla.',
          ),
          action: ref != null
              ? SnackBarAction(
                  label: 'Test onay',
                  onPressed: () async {
                    await _api.confirmTournamentPayment(widget.tournamentId, ref);
                    _load();
                  },
                )
              : null,
          duration: const Duration(seconds: 8),
        ),
      );
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _t == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Turnuva')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final t = _t!;
    final my = t['myEntry'] as Map<String, dynamic>?;
    final registered = my != null;
    final pending = my?['paymentStatus'] == 'pending';
    final entries = t['entries'] as List<dynamic>? ?? [];
    final lobbyCode = t['lobbyRoomCode'] as String?;
    final status = t['status'] as String? ?? 'registration';
    final paidOk = registered && !pending;

    return Scaffold(
      appBar: AppBar(title: Text(t['title'] as String? ?? 'Turnuva')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(t['description'] as String? ?? '', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          _infoRow('Ödül havuzu', '${t['prizePoolCoins']} coin'),
          _infoRow('Giriş ücreti', '${t['entryFeeCoins']} coin'),
          if (t['entryFeeTry'] != null) _infoRow('Ücretli katılım', '${t['entryFeeTry']} ₺'),
          _infoRow('Oyuncular', '${t['entryCount']} / ${t['maxPlayers']}'),
          _infoRow('Min oyuncu', '${t['minPlayers']}'),
          if (t['registrationDeadline'] != null)
            _infoRow('Kayıt sonu', '${t['registrationDeadline']}'),
          const SizedBox(height: 20),
          if (!registered) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _registerCoins,
                icon: const Icon(Icons.monetization_on),
                label: Text('Coin ile katıl (${t['entryFeeCoins']})'),
              ),
            ),
            if (t['entryFeeTry'] != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _registerIap,
                  icon: const Icon(Icons.payment),
                  label: Text('Ücretli katıl (${t['entryFeeTry']} ₺)'),
                ),
              ),
            ],
          ] else if (pending)
            const Card(
              child: ListTile(
                leading: Icon(Icons.hourglass_top, color: Colors.amber),
                title: Text('Ödeme bekleniyor'),
                subtitle: Text('Play Store onayından sonra turnuvaya dahil olursun.'),
              ),
            )
          else ...[
            const Card(
              color: Color(0xFF1B3D2F),
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.greenAccent),
                title: Text('Kayıtlısın'),
                subtitle: Text('Min oyuncu dolunca lobi otomatik açılır.'),
              ),
            ),
            if (paidOk) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _goLobby(t),
                  icon: const Icon(Icons.meeting_room),
                  label: Text(
                    lobbyCode != null || status == 'lobby'
                        ? 'Turnuva lobisine git'
                        : 'Lobiyi bekle / aç',
                  ),
                ),
              ),
            ],
          ],
          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 8),
            child: Text('Kayıtlı oyuncular', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...entries.map((e) {
            final m = e as Map<String, dynamic>;
            return ListTile(
              dense: true,
              leading: const Icon(Icons.person),
              title: Text(m['nick'] as String? ?? '—'),
              trailing: Text(m['paymentStatus'] as String? ?? ''),
            );
          }),
          const SizedBox(height: 12),
          const Text(
            'Altın Lig için Altın rütbe gerekir. Platin+ turnuva coin indirimi.',
            style: TextStyle(fontSize: 12, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Future<void> _goLobby(Map<String, dynamic> t) async {
    final nick = widget.nick ?? await SessionStore().getNick() ?? 'Oyuncu';
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TournamentLobbyScreen(
          tournamentId: widget.tournamentId,
          title: t['title'] as String? ?? 'Turnuva',
          nick: nick,
        ),
      ),
    );
    _load();
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
