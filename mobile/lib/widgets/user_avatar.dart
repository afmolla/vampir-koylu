import 'package:flutter/material.dart';

import '../core/user_defaults.dart';

/// Sol ust profil fotosu — misafir veya kullanici URL.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.nick,
    this.radius = 20,
    this.onTap,
  });

  final String? avatarUrl;
  final String? nick;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final url = (avatarUrl != null && avatarUrl!.isNotEmpty)
        ? avatarUrl!
        : UserDefaults.avatarForNick(nick ?? 'guest');

    final child = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade800,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, _) {},
      child: url.isEmpty
          ? Icon(Icons.person, size: radius, color: Colors.white54)
          : null,
    );

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}
