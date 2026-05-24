import 'dart:convert';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../services/auth_flow.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _nickController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiClient();
  bool _loading = false;
  bool _rememberMe = true;

  String get _locale =>
      Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'tr';

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final data = await _api.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nick: _nickController.text.trim(),
        locale: _locale,
      );
      if (!mounted) return;
      await AuthFlow.completeLogin(
        context,
        data: data,
        locale: _locale,
        rememberMe: _rememberMe,
        loginIdentifier: _emailController.text.trim(),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final err = AuthFlow.parseError(
        e.body.isNotEmpty ? jsonDecode(e.body) : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthFlow.errorMessage(l10n, err))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registerFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nickController.dispose();
    _passwordController.dispose();
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _nickController,
            decoration: InputDecoration(
              labelText: l10n.usernameLabel,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.passwordMinHint,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.rememberMe),
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? true),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _register,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.registerButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.alreadyHaveAccount),
          ),
        ],
      ),
    );
  }
}
