import 'package:flutter/material.dart';

import '../core/user_defaults.dart';

/// Sol ust profil fotosu — misafir veya kullanici URL.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.nick,
    this.frameId,
    this.radius = 20,
    this.onTap,
  });

  final String? avatarUrl;
  final String? nick;
  /// Kuşanılan çerçeve kozmetik id (ör. frame_gold).
  final String? frameId;
  final double radius;
  final VoidCallback? onTap;

  static Color? _frameColor(String? id) {
    if (id == null || id.isEmpty) return null;
    if (id.contains('gold')) return Colors.amber;
    if (id.contains('immortal')) return Colors.deepPurpleAccent;
    return Colors.cyanAccent;
  }

  @override
  Widget build(BuildContext context) {
    final url = (avatarUrl != null && avatarUrl!.isNotEmpty)
        ? avatarUrl!
        : UserDefaults.avatarForNick(nick ?? 'guest');

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade800,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, _) {},
      child: url.isEmpty
          ? Icon(Icons.person, size: radius, color: Colors.white54)
          : null,
    );

    final frameColor = _frameColor(frameId);
    final child = frameColor != null
        ? Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: frameColor, width: 2.5),
            ),
            child: avatar,
          )
        : avatar;

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}
