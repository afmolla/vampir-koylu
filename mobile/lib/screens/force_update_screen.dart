import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

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
  bool _opening = false;

  Future<void> _openUpdate() async {
    final url = widget.updateUrl.trim();
    if (url.isEmpty) {
      _showMsg('Guncelleme linki bos. GitHub: afmolla/flutter/releases');
      return;
    }

    setState(() => _opening = true);
    final uri = Uri.parse(url);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        _showMsg('Tarayici acilamadi. Linki kopyala ve Chrome\'da ac.');
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _copyLink() async {
    if (widget.updateUrl.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: widget.updateUrl));
    _showMsg('Link kopyalandi');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final url = widget.updateUrl;

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
                const SizedBox(height: 24),
                Text(
                  l10n.forceUpdateTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.message ?? l10n.forceUpdateBody,
                  textAlign: TextAlign.center,
                ),
                if (url.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SelectableText(
                    url,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _opening ? null : _openUpdate,
                    child: _opening
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.updateButton),
                  ),
                ),
                if (url.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _copyLink,
                    child: const Text('Linki kopyala'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
