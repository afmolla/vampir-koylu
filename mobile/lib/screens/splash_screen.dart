import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../services/session_store.dart';
import 'force_update_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _api = ApiClient();
  final _session = SessionStore();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final version = await _api.getVersion();
      final allowed = version['allowed'] == true;

      if (!mounted) return;

      if (!allowed) {
        final url = version['updateUrlAndroid'] as String? ?? '';
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ForceUpdateScreen(
              message: version['message'] as String?,
              updateUrl: url,
            ),
          ),
        );
        return;
      }

      final token = await _session.getToken();
      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        final nick = await _session.getNick();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(nick: nick ?? 'Player')),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorNetwork}\n$e'),
          duration: const Duration(seconds: 4),
        ),
      );
      await Future<void>.delayed(const Duration(seconds: 3));
      if (mounted) _bootstrap();
    }
  }

  @override
  void dispose() {
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0F1E), Color(0xFF0D0A12)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nightlight_round,
                size: 72,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.splashLoading),
            ],
          ),
        ),
      ),
    );
  }
}
