import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class MatchSummaryScreen extends StatelessWidget {
  const MatchSummaryScreen({
    super.key,
    required this.summary,
  });

  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kills = summary['kills'] as List<dynamic>? ?? [];
    final lies = summary['lies'] as List<dynamic>? ?? [];
    final most = summary['mostAccused'] as Map<String, dynamic>?;
    final mvp = summary['mvp'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.matchSummaryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _winnerTitle(l10n, summary['winner'] as String?),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _Section(
            title: l10n.summaryKills,
            child: kills.isEmpty
                ? Text(l10n.summaryNone)
                : Column(
                    children: kills.map((k) {
                      final m = k as Map<String, dynamic>;
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.bloodtype, color: Colors.redAccent),
                        title: Text(
                          '${m['killerNick']} → ${m['victimNick']}',
                        ),
                      );
                    }).toList(),
                  ),
          ),
          _Section(
            title: l10n.summaryLies,
            child: lies.isEmpty
                ? Text(l10n.summaryNone)
                : Column(
                    children: lies.map((e) {
                      final m = e as Map<String, dynamic>;
                      return ListTile(
                        dense: true,
                        title: Text('${m['nick']}: ${m['detail']}'),
                      );
                    }).toList(),
                  ),
          ),
          if (most != null)
            _Section(
              title: l10n.summaryMostAccused,
              child: Text('${most['nick']} (${most['count']} oy)'),
            ),
          if (mvp != null)
            _Section(
              title: l10n.summaryMvp,
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('${mvp['nick']} (+${mvp['score']})'),
                ],
              ),
            ),
          Card(
            color: Colors.amber.withValues(alpha: 0.12),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Maç ödülü profiline işlendi (+coin / +XP). '
                      'İlk maç bonusu ve günlük görevleri kontrol et.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.backToLobby),
          ),
        ],
      ),
    );
  }
}

String _winnerTitle(AppLocalizations l10n, String? winner) {
  if (winner == 'vampire') return l10n.vampiresWin;
  if (winner == 'fool') return l10n.foolWins;
  return l10n.villagersWin;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
