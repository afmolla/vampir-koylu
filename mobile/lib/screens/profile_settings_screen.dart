import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_flow.dart';
import '../services/session_store.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _nickController = TextEditingController();
  final _avatarController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nickController.dispose();
    _avatarController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = await SessionStore().getToken();
    if (token == null) return;
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>? ?? {};
      _nickController.text = user['nick'] as String? ?? '';
      _avatarController.text = user['avatarUrl'] as String? ?? '';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final token = await SessionStore().getToken();
      final body = <String, dynamic>{
        'nick': _nickController.text.trim(),
        'avatarUrl': _avatarController.text.trim(),
      };
      if (_passwordController.text.isNotEmpty) {
        body['password'] = _passwordController.text;
      }
      final res = await http.patch(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode != 200) {
        dynamic body;
        try {
          body = jsonDecode(res.body);
        } catch (_) {}
        final code = AuthFlow.parseError(body);
        if (mounted && code != null) {
          final l10n = AppLocalizations.of(context)!;
          throw Exception(AuthFlow.errorMessage(l10n, code));
        }
        throw Exception('HTTP ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>? ?? {};
      await SessionStore().saveSession(
        token: token!,
        userId: user['id'] as String,
        nick: user['nick'] as String,
        locale: user['locale'] as String? ?? 'tr',
        avatarUrl: user['avatarUrl'] as String?,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil ayarları')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil ayarları')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nickController,
            decoration: const InputDecoration(labelText: 'Nick'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _avatarController,
            decoration: const InputDecoration(labelText: 'Avatar URL'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Yeni şifre (isteğe bağlı)',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
