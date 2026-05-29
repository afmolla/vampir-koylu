import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_roles.dart';
import '../widgets/user_avatar.dart';

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
      ),
    );
  }
}

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    required this.nick,
    required this.avatarUrl,
    required this.frameId,
    required this.rankTier,
    required this.rankLabel,
    required this.rankPercent,
    required this.xpToNext,
    required this.nextRankLabel,
    required this.loginStreak,
    this.email,
    this.isGuest = false,
    this.createdAt,
    this.canClaimDaily = false,
    this.onAvatarTap,
    this.onClaimDaily,
  });

  final String nick;
  final String avatarUrl;
  final String? frameId;
  final String rankTier;
  final String rankLabel;
  final int rankPercent;
  final num xpToNext;
  final String? nextRankLabel;
  final int loginStreak;
  final String? email;
  final bool isGuest;
  final String? createdAt;
  final bool canClaimDaily;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onClaimDaily;

  @override
  Widget build(BuildContext context) {
    final rank = kRankThemes[rankTier] ?? kRankThemes['bronze']!;
    final memberSince = _formatDate(createdAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(rank['color'] as int).withValues(alpha: 0.35),
              Colors.black87,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  child: UserAvatar(
                    avatarUrl: avatarUrl,
                    nick: nick,
                    frameId: frameId,
                    radius: 40,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              nick,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isGuest) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Misafir',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (email != null && email!.isNotEmpty)
                        Text(
                          email!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            rank['icon'] as IconData,
                            size: 16,
                            color: Color(rank['color'] as int),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rankLabel,
                            style: TextStyle(
                              color: Color(rank['color'] as int),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (memberSince != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Uye: $memberSince',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (rankPercent / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white12,
                color: Color(rank['color'] as int),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nextRankLabel != null
                  ? '%$rankPercent → $nextRankLabel · $xpToNext XP'
                  : 'En ust rutbe',
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniBadge(
                  icon: Icons.local_fire_department,
                  label: 'Seri',
                  value: '$loginStreak gun',
                  color: Colors.deepOrangeAccent,
                ),
                const SizedBox(width: 8),
                if (canClaimDaily && onClaimDaily != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onClaimDaily,
                      icon: const Icon(Icons.card_giftcard, size: 18),
                      label: const Text('Gunluk bonus'),
                    ),
                  )
                else
                  const Expanded(
                    child: _MiniBadge(
                      icon: Icons.check_circle_outline,
                      label: 'Gunluk',
                      value: 'Alindi',
                      color: Colors.greenAccent,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _formatDate(String? iso) {
    if (iso == null || iso.length < 10) return null;
    final parts = iso.substring(0, 10).split('-');
    if (parts.length != 3) return iso.substring(0, 10);
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileEconomyRow extends StatelessWidget {
  const ProfileEconomyRow({
    super.key,
    required this.coins,
    required this.balance,
    required this.xp,
  });

  final int coins;
  final int balance;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _EcoChip(icon: Icons.monetization_on, label: 'Coin', value: '$coins', color: Colors.amber)),
        const SizedBox(width: 8),
        Expanded(child: _EcoChip(icon: Icons.account_balance_wallet, label: 'Bakiye', value: '$balance ₺', color: Colors.lightGreenAccent)),
        const SizedBox(width: 8),
        Expanded(child: _EcoChip(icon: Icons.bolt, label: 'XP', value: '$xp', color: Colors.cyanAccent)),
      ],
    );
  }
}

class _EcoChip extends StatelessWidget {
  const _EcoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class ProfileStatsGrid extends StatelessWidget {
  const ProfileStatsGrid({super.key, required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Mac', '${stats['totalMatches'] ?? 0}', Icons.sports_esports),
      ('Galibiyet', '${stats['wins'] ?? 0}', Icons.emoji_events),
      ('Oran', '%${stats['winRate'] ?? 0}', Icons.percent),
      ('MVP', '${stats['mvpCount'] ?? 0}', Icons.star),
      ('Turnuva', '${stats['tournamentsJoined'] ?? 0}', Icons.military_tech),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (e) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 48) / 3 - 4,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Icon(e.$3, size: 18, color: Colors.amber),
                      const SizedBox(height: 4),
                      Text(e.$2, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(e.$1, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ProfileEquippedRow extends StatelessWidget {
  const ProfileEquippedRow({
    super.key,
    required this.profile,
    required this.onShopTap,
  });

  final Map<String, dynamic> profile;
  final VoidCallback onShopTap;

  static const _slots = [
    ('equippedFrame', 'Cerceve', Icons.crop_square),
    ('equippedTheme', 'Tema', Icons.palette_outlined),
    ('equippedEffect', 'Efekt', Icons.auto_awesome),
    ('equippedSkin', 'Skin', Icons.face_retouching_natural),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Kusanilan kozmetik', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: onShopTap, child: const Text('Magaza')),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _slots.map((s) {
                final id = profile[s.$1] as String?;
                final label = id == null || id.isEmpty ? 'Varsayilan' : _friendly(id);
                return Chip(
                  avatar: Icon(s.$3, size: 16),
                  label: Text('${s.$2}: $label'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static String _friendly(String id) {
    return id
        .replaceAll('_', ' ')
        .replaceAll('skin vampire', 'Vampir')
        .replaceAll('frame gold', 'Altin cerceve')
        .replaceAll('frame immortal', 'Olumsuz')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class ProfileQuestList extends StatelessWidget {
  const ProfileQuestList({
    super.key,
    required this.title,
    required this.quests,
    required this.titleForId,
    this.onClaim,
  });

  final String title;
  final List<dynamic> quests;
  final String Function(String id) titleForId;
  final void Function(String id)? onClaim;

  @override
  Widget build(BuildContext context) {
    if (quests.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionTitle(title),
        ...quests.map((q) {
          final m = q as Map<String, dynamic>;
          final id = m['id'] as String? ?? '';
          final progress = m['progress'] as int? ?? 0;
          final goal = m['goal'] as int? ?? 1;
          final done = progress >= goal;
          final claimed = m['claimed'] == true;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              title: Text(titleForId(id)),
              subtitle: LinearProgressIndicator(
                value: (progress / goal).clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: Colors.white12,
                color: Colors.amber,
              ),
              trailing: done && !claimed && onClaim != null
                  ? FilledButton(
                      onPressed: () => onClaim!(id),
                      child: const Text('Al'),
                    )
                  : Text(claimed ? '✓' : '$progress/$goal'),
            ),
          );
        }),
      ],
    );
  }
}

class ProfileSeasonMini extends StatelessWidget {
  const ProfileSeasonMini({
    super.key,
    required this.season,
    required this.onOpenSeason,
  });

  final Map<String, dynamic>? season;
  final VoidCallback onOpenSeason;

  @override
  Widget build(BuildContext context) {
    if (season == null) return const SizedBox.shrink();
    final xp = season!['seasonXp'] as int? ?? 0;
    final tiers = season!['tiers'] as List<dynamic>? ?? [];
    Map<String, dynamic>? next;
    for (final t in tiers) {
      final m = t as Map<String, dynamic>;
      if (m['unlocked'] != true) {
        next = m;
        break;
      }
    }
    final nextXp = next?['xp'] as int? ?? 0;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
        title: const Text('Sezon pass'),
        subtitle: Text(
          next != null
              ? 'Sezon XP: $xp · Sonraki kademe: $nextXp XP'
              : 'Sezon XP: $xp · Tum kademeler acik',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpenSeason,
      ),
    );
  }
}

class ProfileRecentMatches extends StatelessWidget {
  const ProfileRecentMatches({
    super.key,
    required this.matches,
    required this.locale,
    required this.onSeeAll,
  });

  final List<dynamic> matches;
  final String locale;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: ProfileSectionTitle('Son maclar')),
            TextButton(onPressed: onSeeAll, child: const Text('Tumu')),
          ],
        ),
        ...matches.take(3).map((row) {
          final m = row as Map<String, dynamic>;
          final roleId = m['role'] as String? ?? 'villager';
          final meta = kGameRoles[roleId];
          final won = m['won'] == true;
          final mvp = m['mvp'] == true;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: meta?.color.withValues(alpha: 0.3) ?? Colors.grey,
                child: Icon(meta?.icon ?? Icons.person, size: 18, color: meta?.color),
              ),
              title: Text(
                '${meta?.label(locale) ?? roleId} · ${m['roomCode'] ?? '?'}',
              ),
              subtitle: Text(_formatDate(m['createdAt'] as String?)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (mvp) const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Icon(
                    won ? Icons.check_circle : Icons.cancel,
                    color: won ? Colors.greenAccent : Colors.redAccent,
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.length < 16) return '';
    return iso.substring(0, 16).replaceFirst('T', ' ');
  }
}

class ProfileReferralCard extends StatelessWidget {
  const ProfileReferralCard({
    super.key,
    required this.code,
    required this.controller,
    required this.onApply,
  });

  final String code;
  final TextEditingController controller;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Davet kodun', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: Colors.amber,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kod kopyalandi')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Arkadasinin kodu',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: onApply, child: const Text('Uygula')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileQuickActions extends StatelessWidget {
  const ProfileQuickActions({super.key, required this.actions});

  final List<({IconData icon, String label, VoidCallback onTap})> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions
          .map(
            (a) => ActionChip(
              avatar: Icon(a.icon, size: 18),
              label: Text(a.label),
              onPressed: a.onTap,
            ),
          )
          .toList(),
    );
  }
}
