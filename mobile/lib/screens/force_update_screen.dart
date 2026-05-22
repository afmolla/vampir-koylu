import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/app_localizations.dart';
import '../services/apk_installer.dart';
import '../services/app_settings_launcher.dart';

import '../core/config.dart';

final _defaultApkUrl = AppConfig.defaultUpdateApkUrl;

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
  bool _confirmedUninstalled = false;

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
    if (u.isEmpty || u.contains('/releases/latest') || !u.endsWith('.apk')) {
      return _defaultApkUrl;
    }
    return u;
  }

  Future<void> _openUninstallDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await AppSettingsLauncher.openUninstallDialog();
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.uninstallDialogOpened),
          duration: const Duration(seconds: 8),
        ),
      );
    } else {
      final fallback = await AppSettingsLauncher.openUninstallSettings();
      if (!mounted) return;
      if (fallback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uninstallSettingsOpened)),
        );
      } else {
        _showError(l10n.uninstallSettingsFailed);
      }
    }
  }

  Future<void> _downloadAndInstall() async {
    if (!_confirmedUninstalled) {
      _showError(AppLocalizations.of(context)!.mustConfirmUninstall);
      return;
    }

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
      if (mounted) {
        _showError('${AppLocalizations.of(context)!.packageConflictAfterInstall}\n\n$e');
      }
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
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 8),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Colors.amber.shade400,
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
                const SizedBox(height: 4),
                Text(
                  l10n.updateApkTarget(AppConfig.updateTargetVersion),
                  style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.message ?? l10n.forceUpdateBody,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.45)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.packageConflictTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.packageConflictBody,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.forceUpdateSteps,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _downloading ? null : _openUninstallDialog,
                    icon: const Icon(Icons.delete_forever),
                    label: Text(l10n.uninstallAppButton),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _confirmedUninstalled,
                  onChanged: _downloading
                      ? null
                      : (v) => setState(() => _confirmedUninstalled = v ?? false),
                  title: Text(
                    l10n.confirmUninstalled,
                    style: const TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_downloading) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                  const SizedBox(height: 12),
                  Text(l10n.downloading(percent)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_confirmedUninstalled && !_downloading)
                        ? _downloadAndInstall
                        : null,
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
