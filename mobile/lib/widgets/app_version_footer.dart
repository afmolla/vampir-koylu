import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/config.dart';

/// Giriş ve alt sayfalarda en altta sürüm + build gösterir.
class AppVersionFooter extends StatefulWidget {
  const AppVersionFooter({super.key});

  @override
  State<AppVersionFooter> createState() => _AppVersionFooterState();
}

class _AppVersionFooterState extends State<AppVersionFooter> {
  String _label = '…';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final v = info.version.isNotEmpty ? info.version : AppConfig.clientVersion;
      final build = info.buildNumber;
      if (mounted) {
        setState(() => _label = 'v$v+$build');
      }
    } catch (_) {
      if (mounted) setState(() => _label = 'v${AppConfig.clientVersion}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        _label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
