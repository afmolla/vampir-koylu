import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/apk_installer.dart';

const _defaultApkUrl =
    'https://github.com/afmolla/flutter/releases/download/v0.1.8/app-release.apk';

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
  final _installer = ApkInstaller();
  String _installedVersion = '…';
  double _progress = 0;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_downloading) _downloadAndInstall();
    });
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

  Future<void> _downloadAndInstall() async {
    setState(() {
      _downloading = true;
      _progress = 0;
    });

    try {
      await _installer.downloadAndInstall(
        url: _apkUrl,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.installOpened),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on ApkInstallException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) {
        _showError('${AppLocalizations.of(context)!.downloadFailed}\n$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
        });
      }
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (_progress * 100).clamp(0, 100).toInt();

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
                  '${l10n.installedVersion} $_installedVersion',
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.message ?? l10n.forceUpdateBody,
                  textAlign: TextAlign.center,
                ),
                if (_downloading) ...[
                  const SizedBox(height: 28),
                  LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                  const SizedBox(height: 12),
                  Text(l10n.downloading(percent)),
                ],
                const SizedBox(height: 28),
                if (!_downloading)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _downloadAndInstall,
                      icon: const Icon(Icons.download_for_offline),
                      label: Text(l10n.downloadAndInstall),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
