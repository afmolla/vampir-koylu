import 'package:flutter/material.dart';

class GameRoleMeta {
  const GameRoleMeta({
    required this.id,
    required this.labelTr,
    required this.labelEn,
    required this.icon,
    required this.color,
    required this.isEvil,
  });

  final String id;
  final String labelTr;
  final String labelEn;
  final IconData icon;
  final Color color;
  final bool isEvil;

  String label(String locale) => locale == 'en' ? labelEn : labelTr;
}

const kGameRoles = <String, GameRoleMeta>{
  'vampire': GameRoleMeta(
    id: 'vampire',
    labelTr: 'Vampir',
    labelEn: 'Vampire',
    icon: Icons.bloodtype_rounded,
    color: Color(0xFFB71C3A),
    isEvil: true,
  ),
  'silent_killer': GameRoleMeta(
    id: 'silent_killer',
    labelTr: 'Sessiz Katil',
    labelEn: 'Silent Killer',
    icon: Icons.visibility_off_rounded,
    color: Color(0xFF6A1B9A),
    isEvil: true,
  ),
  'double_agent': GameRoleMeta(
    id: 'double_agent',
    labelTr: 'Çifte Ajan',
    labelEn: 'Double Agent',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFF4E342E),
    isEvil: true,
  ),
  'doctor': GameRoleMeta(
    id: 'doctor',
    labelTr: 'Doktor',
    labelEn: 'Doctor',
    icon: Icons.medical_services_rounded,
    color: Color(0xFF2E7D52),
    isEvil: false,
  ),
  'hunter': GameRoleMeta(
    id: 'hunter',
    labelTr: 'Avcı',
    labelEn: 'Hunter',
    icon: Icons.sports_martial_arts_rounded,
    color: Color(0xFF5D4037),
    isEvil: false,
  ),
  'seer': GameRoleMeta(
    id: 'seer',
    labelTr: 'Kahin',
    labelEn: 'Seer',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF5C6BC0),
    isEvil: false,
  ),
  'guard': GameRoleMeta(
    id: 'guard',
    labelTr: 'Koruyucu',
    labelEn: 'Guard',
    icon: Icons.shield_rounded,
    color: Color(0xFF455A64),
    isEvil: false,
  ),
  'fool': GameRoleMeta(
    id: 'fool',
    labelTr: 'Deli',
    labelEn: 'Fool',
    icon: Icons.psychology_alt_rounded,
    color: Color(0xFFFF8F00),
    isEvil: false,
  ),
  'cursed_villager': GameRoleMeta(
    id: 'cursed_villager',
    labelTr: 'Lanetli Köylü',
    labelEn: 'Cursed Villager',
    icon: Icons.coronavirus_rounded,
    color: Color(0xFF6D4C41),
    isEvil: false,
  ),
  'wizard': GameRoleMeta(
    id: 'wizard',
    labelTr: 'Büyücü',
    labelEn: 'Wizard',
    icon: Icons.auto_fix_high_rounded,
    color: Color(0xFF7B1FA2),
    isEvil: false,
  ),
  'sheriff': GameRoleMeta(
    id: 'sheriff',
    labelTr: 'Şerif',
    labelEn: 'Sheriff',
    icon: Icons.local_police_rounded,
    color: Color(0xFFC9A227),
    isEvil: false,
  ),
  'villager': GameRoleMeta(
    id: 'villager',
    labelTr: 'Köylü',
    labelEn: 'Villager',
    icon: Icons.cottage_rounded,
    color: Color(0xFF388E3C),
    isEvil: false,
  ),
};

GameRoleMeta roleMeta(String? role) =>
    kGameRoles[role] ?? kGameRoles['villager']!;

const kRankThemes = <String, Map<String, dynamic>>{
  'bronze': {'label': 'Bronz Köylü', 'labelEn': 'Bronze Villager', 'color': 0xFFCD7F32, 'icon': Icons.shield_moon_outlined},
  'silver': {'label': 'Gümüş Avcı', 'labelEn': 'Silver Hunter', 'color': 0xFF90A4AE, 'icon': Icons.military_tech_outlined},
  'gold': {'label': 'Altın Stratej', 'labelEn': 'Gold Strategist', 'color': 0xFFFFB300, 'icon': Icons.workspace_premium_outlined},
  'platinum': {'label': 'Platin Usta', 'labelEn': 'Platinum Master', 'color': 0xFF26C6DA, 'icon': Icons.diamond_outlined},
  'diamond': {'label': 'Elmas Efsane', 'labelEn': 'Diamond Legend', 'color': 0xFF7E57C2, 'icon': Icons.auto_awesome},
  'immortal_vampire': {'label': 'Ölümsüz Vampir', 'labelEn': 'Immortal Vampire', 'color': 0xFFB71C3A, 'icon': Icons.bloodtype_rounded},
};

String rankLabel(String tier, String locale) {
  final m = kRankThemes[tier] ?? kRankThemes['bronze']!;
  return locale == 'en' ? (m['labelEn'] as String) : (m['label'] as String);
}
