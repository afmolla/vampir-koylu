import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app.dart';
import '../core/config.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_version_footer.dart';
import '../services/api_client.dart';
import '../services/auth_config.dart';
import '../services/auth_flow.dart';
import '../services/session_store.dart';
import 'offline_entry_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nickController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiClient();
  final _session = SessionStore();
  bool _loading = false;
  bool _authConfigReady = false;

  bool _rememberMe = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _loadAuthConfig();
    _loadSaved();
  }

  Future<void> _loadAuthConfig() async {
    await AuthConfig.load();
    if (mounted) setState(() => _authConfigReady = true);
  }

  Future<void> _loadSaved() async {
    final nick = await _session.getNick();
    final remember = await _session.getRememberMe();
    if (!mounted) return;
    setState(() {
      _rememberMe = remember;
      if (nick != null && nick.isNotEmpty) _nickController.text = nick;
    });
  }

  String get _locale =>
      Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'tr';

  Future<void> _finishLogin(Map<String, dynamic> data) async {
    await AuthFlow.completeLogin(
      context,
      data: data,
      locale: _locale,
      rememberMe: _rememberMe,
    );
  }

  void _showApiError(ApiException e) {
    final l10n = AppLocalizations.of(context)!;
    dynamic body;
    try {
      body = jsonDecode(e.body);
    } catch (_) {}
    final code = AuthFlow.parseError(body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AuthFlow.errorMessage(l10n, code))),
    );
  }

  Future<void> _guestLogin() async {
    final nick = _nickController.text.trim();
    if (nick.length < 2) return;
    setState(() => _loading = true);
    try {
      final data = await _api.guestLogin(nick: nick, locale: _locale);
      if (!mounted) return;
      await _finishLogin(data);
    } on ApiException catch (e) {
      if (mounted) _showApiError(e);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorNetwork)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _emailLogin() async {
    setState(() => _loading = true);
    try {
      final data = await _api.login(
        login: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await _finishLogin(data);
    } on ApiException catch (e) {
      if (mounted) _showApiError(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loginFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    await AuthConfig.load(forceRefresh: true);
    final clientId = AuthConfig.googleServerClientId;
    if (clientId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorGoogleNotConfigured),
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final google = GoogleSignIn(
        serverClientId: clientId,
      );
      final account = await google.signIn();
      if (account == null) return;
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('no_id_token');
      final data = await _api.googleLogin(idToken: idToken);
      if (!mounted) return;
      await _finishLogin(data);
    } on ApiException catch (e) {
      if (mounted) _showApiError(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.googleLoginCancelled),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _facebookLogin() async {
    setState(() => _loading = true);
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return;
      final token = result.accessToken?.tokenString;
      if (token == null) return;
      final data = await _api.facebookLogin(accessToken: token);
      if (!mounted) return;
      await _finishLogin(data);
    } on ApiException catch (e) {
      if (mounted) _showApiError(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.facebookLoginCancelled),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nickController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        l10n.appTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 20),
                      _LanguageRow(locale: _locale),
                      const SizedBox(height: 20),
                      SegmentedButton<int>(
                        segments: [
                          ButtonSegment(value: 0, label: Text(l10n.accountTab)),
                          ButtonSegment(value: 1, label: Text(l10n.guestTab)),
                        ],
                        selected: {_tab},
                        onSelectionChanged: (s) =>
                            setState(() => _tab = s.first),
                      ),
                      const SizedBox(height: 20),
                      if (_tab == 0) ...[
                        TextField(
                          controller: _emailController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.loginIdentifier,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.passwordLabel,
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(l10n.createAccount),
                            ),
                            TextButton(
                              onPressed: _loading
                                  ? null
                                  : () async {
                                      final mail = _emailController.text.trim();
                                      if (!mail.contains('@')) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.enterEmailForReset,
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      try {
                                        await _api.forgotPassword(email: mail);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.resetLinkSent),
                                          ),
                                        );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text('$e')),
                                          );
                                        }
                                      }
                                    },
                              child: Text(l10n.forgotPassword),
                            ),
                          ],
                        ),
                        FilledButton(
                          onPressed: _loading ? null : _emailLogin,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.signIn),
                        ),
                      ] else ...[
                        TextField(
                          controller: _nickController,
                          decoration: InputDecoration(
                            hintText: l10n.guestNickHint,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          onSubmitted: (_) => _guestLogin(),
                        ),
                        FilledButton(
                          onPressed: _loading ? null : _guestLogin,
                          child: Text(l10n.guestPlay),
                        ),
                      ],
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.rememberMe),
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? true),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: (_loading || !_authConfigReady)
                            ? null
                            : (AuthConfig.hasGoogleClientId
                                ? _googleLogin
                                : () async {
                                    await AuthConfig.load(forceRefresh: true);
                                    if (!mounted) return;
                                    if (AuthConfig.hasGoogleClientId) {
                                      await _googleLogin();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.errorGoogleNotConfigured,
                                          ),
                                          duration: const Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  }),
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: Text(
                          AuthConfig.hasGoogleClientId
                              ? l10n.googleSignIn
                              : l10n.googleConfiguring,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (AuthConfig.facebookSignInEnabled)
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _facebookLogin,
                          icon: const Icon(Icons.facebook),
                          label: Text(l10n.facebookSignIn),
                        ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OfflineEntryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.wifi_off_rounded, size: 20),
                        label: Text(l10n.continueOffline),
                      ),
                    ],
                  ),
                ),
              ),
              const AppVersionFooter(),
            ],
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
