import 'package:flutter/material.dart';

import '../models/game_roles.dart';

class RankProgressCard extends StatelessWidget {
  const RankProgressCard({
    super.key,
    required this.profile,
    required this.rankProgress,
    required this.locale,
  });

  final Map<String, dynamic> profile;
  final Map<String, dynamic>? rankProgress;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final tier = profile['rankTier'] as String? ?? 'bronze';
    final rank = kRankThemes[tier] ?? kRankThemes['bronze']!;
    final percent = (rankProgress?['percent'] as num?)?.toInt() ?? 0;
    final xpToNext = rankProgress?['xpToNext'] as num? ?? 0;
    final nextId = rankProgress?['nextId'] as String?;
    final nextLabel = nextId != null ? rankLabel(nextId, locale) : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(rank['color'] as int),
                  child: Icon(rank['icon'] as IconData, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rankLabel(tier, locale),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        locale == 'en'
                            ? (profile['rankPerkEn'] as String? ?? '')
                            : (profile['rankPerkTr'] as String? ?? ''),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white12,
                color: Color(rank['color'] as int),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nextLabel != null
                  ? (locale == 'en'
                      ? '$percent% to $nextLabel · $xpToNext XP left'
                      : '%$percent → $nextLabel · $xpToNext XP kaldı')
                  : (locale == 'en' ? 'Max rank reached' : 'En üst rütbe'),
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              '${profile['xp']} XP · ${profile['coins']} coin',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
