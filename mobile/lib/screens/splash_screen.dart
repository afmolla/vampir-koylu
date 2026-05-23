import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/server_config.dart';
import '../core/version_utils.dart';
import '../l10n/app_localizations.dart';
import '../services/api_client.dart';
import '../services/session_store.dart';
import 'force_update_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'offline_entry_screen.dart';

enum _CheckStep { pending, running, ok, failed }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _api = ApiClient();
  _CheckStep _serverStep = _CheckStep.running;
  _CheckStep _versionStep = _CheckStep.pending;
  String _clientVersion = '…';
  String? _latestVersion;
  String? _errorMessage;
  bool _retrying = false;
  bool _serverUnreachable = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  void _setSteps({
    required _CheckStep server,
    required _CheckStep version,
    String? latest,
    String? error,
    bool? serverUnreachable,
  }) {
    if (!mounted) return;
    setState(() {
      _serverStep = server;
      _versionStep = version;
      _latestVersion = latest;
      _errorMessage = error;
      if (serverUnreachable != null) {
        _serverUnreachable = serverUnreachable;
      }
    });
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    setState(() {
      _retrying = false;
      _serverStep = _CheckStep.running;
      _versionStep = _CheckStep.pending;
      _errorMessage = null;
      _latestVersion = null;
      _serverUnreachable = false;
    });

    var serverOk = false;

    try {
      _clientVersion = await _api.currentVersion();
      if (!mounted) return;
      setState(() => _clientVersion = _clientVersion);

      final reachable = await ServerConfig.findReachable();
      if (reachable != null) {
        await ServerConfig.setBaseUrl(reachable);
      }

      await _api.checkServer();
      serverOk = true;
      if (!mounted) return;
      _setSteps(server: _CheckStep.ok, version: _CheckStep.running);

      final version = await _api.getVersion();
      final needsUpdate = shouldForceUpdate(
        clientVersion: _clientVersion,
        versionResponse: version,
      );
      final latest = version['latestVersion'] as String?;
      final serverMisconfigured = latest != null &&
          latest.isNotEmpty &&
          !isVersionOlder(_clientVersion, latest) &&
          isVersionOlder(latest, AppConfig.updateTargetVersion);

      if (!mounted) return;

      if (needsUpdate) {
        _setSteps(
          server: _CheckStep.ok,
          version: _CheckStep.failed,
          latest: latest,
        );
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        final url = resolveUpdateApkUrl(version);
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

      _setSteps(
        server: _CheckStep.ok,
        version: _CheckStep.ok,
        latest: latest,
      );

      if (serverMisconfigured && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sunucu eski ayar ($latest). VPS\'te BASLAT-API.cmd çalıştır.',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }

      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      final session = SessionStore();
      if (await session.getRememberMe()) {
        final token = await session.getToken();
        final nick = await session.getNick();
        if (token != null && token.isNotEmpty && nick != null && nick.isNotEmpty) {
          try {
            final me = await _api.getMe(token: token);
            final user = me['user'] as Map<String, dynamic>?;
            if (user?['id'] != null) {
              await session.saveUserId(user!['id'] as String);
            }
            final avatar = user?['avatarUrl'] as String?;
            if (avatar != null) await session.setAvatarUrl(avatar);
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => HomeScreen(nick: nick, avatarUrl: avatar),
              ),
            );
            return;
          } catch (_) {
            await session.clear();
          }
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final unreachable = !serverOk;
      final tried = ServerConfig.connectionCandidates().join('\n');
      _setSteps(
        server: unreachable ? _CheckStep.failed : _CheckStep.ok,
        version: unreachable ? _CheckStep.pending : _CheckStep.failed,
        error: unreachable
            ? '${l10n.splashServerUnreachable}\n\n'
                'Adres: ${ServerConfig.effectiveBaseUrl}\n\n'
                'Telefonda tarayıcıda dene:\n'
                '${ServerConfig.effectiveBaseUrl}/health\n\n'
                'ok:true görmüyorsan VPS\'te port 3002 ve firewall.\n\n'
                'Denenen:\n$tried'
            : '${l10n.errorNetwork}\n$e',
        serverUnreachable: unreachable,
      );
    }
  }

  void _onRetry() {
    setState(() => _retrying = true);
    _bootstrap().whenComplete(() {
      if (mounted) setState(() => _retrying = false);
    });
  }

  void _onContinueOffline() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OfflineEntryScreen()),
    );
  }

  Future<void> _onResetServer() async {
    await ServerConfig.clearSavedUrl();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sunucu adresi sıfırlandı (85.95.251.204:3002)')),
    );
    _onRetry();
  }

  Future<void> _onChangeServer() async {
    final controller = TextEditingController(text: ServerConfig.effectiveBaseUrl);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sunucu adresi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'http://85.95.251.204:3002',
            labelText: 'API adresi',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kaydet ve dene'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ServerConfig.setBaseUrl(controller.text);
    _onRetry();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  String _serverHostLabel() {
    try {
      final u = Uri.parse(ServerConfig.effectiveBaseUrl);
      return u.hasPort ? '${u.host}:${u.port}' : u.host;
    } catch (_) {
      return ServerConfig.effectiveBaseUrl;
    }
  }

  Widget _stepRow({
    required _CheckStep step,
    required String label,
    String? detail,
  }) {
    final theme = Theme.of(context);
    IconData icon;
    Color? iconColor;
    switch (step) {
      case _CheckStep.pending:
        icon = Icons.radio_button_unchecked;
        iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
      case _CheckStep.running:
        icon = Icons.sync;
        iconColor = theme.colorScheme.secondary;
      case _CheckStep.ok:
        icon = Icons.check_circle;
        iconColor = Colors.greenAccent;
      case _CheckStep.failed:
        icon = Icons.error_outline;
        iconColor = theme.colorScheme.error;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (step == _CheckStep.running)
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 2),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.secondary,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 2),
              child: Icon(icon, size: 22, color: iconColor),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                if (detail != null && detail.isNotEmpty)
                  Text(
                    detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasError = _errorMessage != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0F1E), Color(0xFF0D0A12)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _stepRow(
                        step: _serverStep,
                        label: l10n.splashConnectingServer,
                        detail: l10n.splashServerHost(_serverHostLabel()),
                      ),
                      _stepRow(
                        step: _versionStep,
                        label: l10n.splashCheckingVersion,
                        detail: _clientVersion.isNotEmpty
                            ? l10n.splashYourVersion(_clientVersion)
                            : null,
                      ),
                      if (_latestVersion != null &&
                          _versionStep == _CheckStep.ok)
                        Padding(
                          padding: const EdgeInsets.only(left: 34, top: 4),
                          child: Text(
                            l10n.splashServerVersion(_latestVersion!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasError) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _retrying ? null : _onRetry,
                    icon: _retrying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(l10n.splashRetry),
                  ),
                  if (_serverUnreachable) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _onChangeServer,
                      icon: const Icon(Icons.dns_outlined),
                      label: const Text('Sunucu adresini değiştir'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _retrying ? null : _onResetServer,
                      child: const Text('Varsayılan sunucuya dön (3002)'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _onContinueOffline,
                      icon: const Icon(Icons.wifi_off_rounded),
                      label: Text(l10n.continueOffline),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: const BorderSide(color: Colors.amber),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.continueOfflineHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
