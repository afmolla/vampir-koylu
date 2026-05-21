import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

/// GitHub Releases sayfasi — APK dosyasindan daha guvenilir acilir.
const _releasesPage = 'https://github.com/afmolla/flutter/releases';

const _defaultApkUrl =
    'https://github.com/afmolla/flutter/releases/download/v0.1.6/app-release.apk';

class ForceUpdateScreen extends StatefulWidget {
  const ForceUpdateScreen({
    super.key,
    this.message,
    required this.updateUrl,
  });

  final String? message;
  final String updateUrl;

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  String _installedVersion = '…';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _installedVersion = info.version);
    } catch (_) {}
  }

  String get _apkUrl {
    final u = widget.updateUrl.trim();
    return u.isNotEmpty ? u : _defaultApkUrl;
  }

  Future<bool> _tryOpen(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return true;
      }
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  Future<void> _openReleasesPage() async {
    setState(() => _busy = true);
    final ok = await _tryOpen(_releasesPage);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) _showManualDialog(_releasesPage);
  }

  Future<void> _openApkLink() async {
    setState(() => _busy = true);
    final ok = await _tryOpen(_apkUrl);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      _showMsg('APK acilmadi. Once "GitHub sayfasini ac" kullan.');
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showMsg('Link kopyalandi — Chrome yapistir');
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 4)),
    );
  }

  void _showManualDialog(String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manuel indir'),
        content: SelectableText(
          'Chrome acip su adrese git:\n\n$url\n\n'
          'veya Releases sayfasindan en son APK yi indir.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _copy(url);
              Navigator.pop(ctx);
            },
            child: const Text('Kopyala'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.system_update_alt,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.forceUpdateTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Yuklu surum: $_installedVersion',
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.message ?? l10n.forceUpdateBody,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _openReleasesPage,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('GitHub sayfasini ac (onerilen)'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _openApkLink,
                    icon: const Icon(Icons.download),
                    label: Text(l10n.updateButton),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _copy(_apkUrl),
                  child: const Text('APK linkini kopyala'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
