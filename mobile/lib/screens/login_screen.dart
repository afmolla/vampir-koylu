import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../services/session_store.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nickController = TextEditingController();
  final _api = ApiClient();
  final _session = SessionStore();
  bool _loading = false;

  String get _locale =>
      Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'tr';

  Future<void> _guestLogin() async {
    final nick = _nickController.text.trim();
    if (nick.length < 2) return;

    setState(() => _loading = true);
    try {
      final data = await _api.guestLogin(nick: nick, locale: _locale);
      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>;
      await _session.saveSession(
        token: token,
        nick: user['nick'] as String,
        locale: _locale,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(nick: user['nick'] as String),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorNetwork)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider — yakında / coming soon')),
    );
  }

  @override
  void dispose() {
    _nickController.dispose();
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1020), Color(0xFF0D0A12)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.loginTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 24),
                _LanguageRow(locale: _locale),
                const SizedBox(height: 32),
                TextField(
                  controller: _nickController,
                  decoration: InputDecoration(
                    hintText: l10n.guestNickHint,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _guestLogin(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _guestLogin,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.guestPlay),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => _showSoon('Google'),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(l10n.googleSignIn),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showSoon('Facebook'),
                  icon: const Icon(Icons.facebook),
                  label: Text(l10n.facebookSignIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final switcher = LocaleSwitcher.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.language),
        const SizedBox(width: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'tr', label: Text('TR')),
            ButtonSegment(value: 'en', label: Text('EN')),
          ],
          selected: {locale},
          onSelectionChanged: (set) {
            final code = set.first;
            switcher?.onLocaleChanged(Locale(code));
          },
        ),
      ],
    );
  }
}
