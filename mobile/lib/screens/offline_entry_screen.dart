import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/session_store.dart';
import 'home_screen.dart';

/// Sunucuya ulaşılamadığında: takma ad + botlu solo oyun.
class OfflineEntryScreen extends StatefulWidget {
  const OfflineEntryScreen({super.key});

  @override
  State<OfflineEntryScreen> createState() => _OfflineEntryScreenState();
}

class _OfflineEntryScreenState extends State<OfflineEntryScreen> {
  final _nickController = TextEditingController();
  final _session = SessionStore();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadNick();
  }

  Future<void> _loadNick() async {
    final nick = await _session.getNick();
    if (nick != null && nick.isNotEmpty && mounted) {
      _nickController.text = nick;
    } else if (mounted) {
      _nickController.text = 'Misafir';
    }
  }

  String get _locale =>
      Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'tr';

  Future<void> _startOffline() async {
    final nick = _nickController.text.trim();
    if (nick.length < 2) return;

    setState(() => _loading = true);
    await _session.saveOfflineGuest(nick: nick, locale: _locale);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(nick: nick, offlineMode: true),
      ),
    );
  }

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1528), Color(0xFF0D0A12)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.offlineModeTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.offlineModeBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _nickController,
                  decoration: InputDecoration(
                    hintText: l10n.guestNickHint,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _startOffline(),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _startOffline,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.smart_toy_outlined),
                  label: Text(l10n.offlinePlayWithBots),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.offlineBackToSplash),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
