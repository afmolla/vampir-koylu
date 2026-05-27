import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app.dart';
import '../core/config.dart';
import '../core/user_defaults.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_flow.dart';
import '../services/avatar_upload_service.dart';
import '../services/profile_service.dart';
import '../services/session_store.dart';
import '../widgets/user_avatar.dart';
import 'cosmetic_shop_screen.dart';
import 'match_history_screen.dart';
import 'profile_hub_screen.dart';
import 'register_screen.dart';
import 'season_pass_screen.dart';

/// Profil fotosu, nick, sifre ve hesap ayarlari — ana sayfa avatarina tiklaninca acilir.
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    this.initialNick,
    this.initialAvatarUrl,
    this.offlineMode = false,
  });

  final String? initialNick;
  final String? initialAvatarUrl;
  final bool offlineMode;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _nickController = TextEditingController();
  final _avatarController = TextEditingController();
  final _passwordController = TextEditingController();
  final _profileApi = ProfileService();
  final _avatarUpload = AvatarUploadService();

  String? _email;
  bool _isGuest = true;
  String? _previewAvatar;
  String? _localPreviewPath;
  String? _equippedFrame;
  Map<String, dynamic>? _profileBundle;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String _localeCode = 'tr';
  String _botDifficulty = 'normal';

  static const _avatarStyles = [
    ('avataaars', 'Klasik'),
    ('adventurer', 'Maceraci'),
    ('big-smile', 'Gulumseyen'),
    ('fun-emoji', 'Emoji'),
    ('lorelei', 'Lorelei'),
    ('micah', 'Micah'),
    ('notionists', 'Notion'),
    ('pixel-art', 'Piksel'),
    ('thumbs', 'Bas parmak'),
  ];

  @override
  void initState() {
    super.initState();
    _previewAvatar = widget.initialAvatarUrl;
    _nickController.text = widget.initialNick ?? '';
    _load();
  }

  @override
  void dispose() {
    _nickController.dispose();
    _avatarController.dispose();
    _passwordController.dispose();
    _profileApi.dispose();
    super.dispose();
  }

  String _diceBearUrl(String style, String seed) =>
      'https://api.dicebear.com/7.x/$style/png?seed=${Uri.encodeComponent(seed)}';

  Future<void> _load() async {
    if (widget.offlineMode) {
      final url = await SessionStore().getAvatarUrl();
      if (mounted) {
        setState(() {
          _loading = false;
          _previewAvatar = url ?? UserDefaults.avatarForNick(_nickController.text);
        });
      }
      return;
    }

    final token = await SessionStore().getToken();
    if (token == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final locale = await SessionStore().getLocale();
      final results = await Future.wait([
        http.get(
          Uri.parse('${AppConfig.apiBaseUrl}/api/auth/me'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        _profileApi.fetchProfile(),
      ]);

      if (results[0] is http.Response && (results[0] as http.Response).statusCode == 200) {
        final data =
            jsonDecode((results[0] as http.Response).body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>? ?? {};
        _email = user['email'] as String?;
        _isGuest = user['isGuest'] as bool? ?? true;
        _nickController.text = user['nick'] as String? ?? _nickController.text;
        final avatar = user['avatarUrl'] as String? ?? '';
        _avatarController.text = avatar;
        _previewAvatar = avatar.isNotEmpty ? avatar : null;
        _localeCode = user['locale'] as String? ?? locale;
      }

      final bundle = results[1] as Map<String, dynamic>;
      final profile = bundle['profile'] as Map<String, dynamic>? ?? {};
      _profileBundle = bundle;
      _equippedFrame = profile['equippedFrame'] as String?;
      _botDifficulty = profile['botDifficulty'] as String? ?? 'normal';
    } catch (_) {
      /* kismi yukleme */
    }

    if (mounted) setState(() => _loading = false);
  }

  void _setPreviewAvatar(String url, {String? localPath}) {
    setState(() {
      _previewAvatar = url;
      _localPreviewPath = localPath;
      _avatarController.text = url;
    });
  }

  Future<bool> _ensurePermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    final req = await permission.request();
    return req.isGranted;
  }

  Future<void> _uploadPickedFile(XFile file, {BuildContext? sheetContext}) async {
    final token = await SessionStore().getToken();
    if (token == null) return;

    setState(() {
      _uploadingAvatar = true;
      _localPreviewPath = file.path;
    });

    try {
      final url = await _avatarUpload.uploadFile(file, token);
      await SessionStore().setAvatarUrl(url);
      if (!mounted) return;
      _setPreviewAvatar(url);
      if (sheetContext != null && sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil fotografi yuklendi')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _pickFromDevice(ImageSource source, BuildContext sheetContext) async {
    if (source == ImageSource.camera) {
      if (!await _ensurePermission(Permission.camera)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kamera izni gerekli')),
          );
        }
        return;
      }
    } else {
      final photos = await _ensurePermission(Permission.photos);
      final storage = photos || await _ensurePermission(Permission.storage);
      if (!photos && !storage) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Galeri izni gerekli')),
          );
        }
        return;
      }
    }

    final file = source == ImageSource.camera
        ? await _avatarUpload.pickFromCamera()
        : await _avatarUpload.pickFromGallery();
    if (file == null) return;
    await _uploadPickedFile(file, sheetContext: sheetContext);
  }

  Future<void> _pickAvatar() async {
    final seed = _nickController.text.trim().isEmpty
        ? 'player'
        : _nickController.text.trim();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ListView(
                controller: scrollController,
                children: [
                  const Text(
                    'Profil fotografi sec',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _uploadingAvatar
                              ? null
                              : () => _pickFromDevice(ImageSource.gallery, ctx),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Galeri'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _uploadingAvatar
                              ? null
                              : () => _pickFromDevice(ImageSource.camera, ctx),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Kamera'),
                        ),
                      ),
                    ],
                  ),
                  if (_uploadingAvatar) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 4),
                    const Text(
                      'Yukleniyor...',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Hazir avatarlar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _avatarStyles.length,
                    itemBuilder: (_, i) {
                      final style = _avatarStyles[i].$1;
                      final url = _diceBearUrl(style, seed);
                      final selected = _previewAvatar == url;
                      return InkWell(
                        onTap: () {
                          _setPreviewAvatar(url);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? Colors.amber
                                  : Colors.white24,
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.network(url, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _avatarController,
                    decoration: const InputDecoration(
                      labelText: 'Ozel resim URL',
                      hintText: 'https://...',
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _previewAvatar = v.trim()),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      final url = _avatarController.text.trim();
                      if (url.isNotEmpty) _setPreviewAvatar(url);
                      Navigator.pop(ctx);
                    },
                    child: const Text('URL ile kullan'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    if (widget.offlineMode) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cevrimdisi modda profil kaydi icin kayit ol'),
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final token = await SessionStore().getToken();
      final body = <String, dynamic>{
        'nick': _nickController.text.trim(),
        'avatarUrl': (_previewAvatar ?? _avatarController.text).trim(),
        'botDifficulty': _botDifficulty,
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
        dynamic errBody;
        try {
          errBody = jsonDecode(res.body);
        } catch (_) {}
        final code = AuthFlow.parseError(errBody);
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
        locale: _localeCode,
        avatarUrl: user['avatarUrl'] as String?,
      );
      await SessionStore().setLocale(_localeCode);
      if (!mounted) return;
      LocaleSwitcher.of(context)?.onLocaleChanged(Locale(_localeCode));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil guncellendi')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil ve ayarlar')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final displayNick = _nickController.text.trim().isEmpty
        ? (widget.initialNick ?? 'Oyuncu')
        : _nickController.text.trim();
    final avatarUrl = _previewAvatar ??
        (_avatarController.text.trim().isNotEmpty
            ? _avatarController.text.trim()
            : UserDefaults.avatarForNick(displayNick));
    final localPath = _localPreviewPath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil ve ayarlar'),
        actions: [
          if (!widget.offlineMode)
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (widget.offlineMode)
            MaterialBanner(
              content: const Text(
                'Cevrimdisi mod. Profili kaydetmek icin hesap olustur.',
              ),
              leading: const Icon(Icons.wifi_off, color: Colors.amber),
              actions: [
                TextButton(
                  onPressed: () => _open(const RegisterScreen()),
                  child: const Text('Kayit ol'),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    if (localPath != null && File(localPath).existsSync())
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: FileImage(File(localPath)),
                      )
                    else
                      UserAvatar(
                        avatarUrl: avatarUrl,
                        nick: displayNick,
                        frameId: _equippedFrame,
                        radius: 48,
                      ),
                    if (_uploadingAvatar)
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.black54,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    Material(
                      color: Colors.amber,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.offlineMode || _uploadingAvatar
                            ? null
                            : _pickAvatar,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.camera_alt, size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  displayNick,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_email != null && _email!.isNotEmpty)
                  Text(
                    _email!,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                if (!widget.offlineMode) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _uploadingAvatar ? null : _pickAvatar,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Profil fotosunu degistir'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Hesap'),
          TextField(
            controller: _nickController,
            enabled: !widget.offlineMode,
            decoration: const InputDecoration(
              labelText: 'Nick',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          if (!widget.offlineMode && !_isGuest) ...[
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni sifre (istege bagli)',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (!widget.offlineMode) ...[
            DropdownButtonFormField<String>(
              value: _localeCode,
              decoration: const InputDecoration(
                labelText: 'Dil',
                prefixIcon: Icon(Icons.language),
              ),
              items: const [
                DropdownMenuItem(value: 'tr', child: Text('Turkce')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _localeCode = v);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _botDifficulty,
              decoration: const InputDecoration(
                labelText: 'Bot zorlugu (lobi)',
                prefixIcon: Icon(Icons.smart_toy_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Kolay')),
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: 'hard', child: Text('Zor')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _botDifficulty = v);
              },
            ),
          ],
          const SizedBox(height: 20),
          const _SectionTitle('Oyun profili'),
          _NavTile(
            icon: Icons.military_tech_outlined,
            title: 'Profil, rutbe ve gorevler',
            subtitle: 'Istatistik, gunluk bonus, davet kodu',
            onTap: widget.offlineMode
                ? null
                : () => _open(const ProfileHubScreen()),
          ),
          _NavTile(
            icon: Icons.storefront_outlined,
            title: 'Kozmetik magaza',
            subtitle: 'Cerceve, tema, efekt',
            onTap: widget.offlineMode
                ? null
                : () => _open(CosmeticShopScreen(bundle: _profileBundle)),
          ),
          _NavTile(
            icon: Icons.auto_awesome,
            title: 'Sezon pass',
            onTap: widget.offlineMode ? null : () => _open(const SeasonPassScreen()),
          ),
          _NavTile(
            icon: Icons.history,
            title: 'Mac gecmisi',
            onTap: widget.offlineMode ? null : () => _open(const MatchHistoryScreen()),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Ayarlar'),
          _NavTile(
            icon: Icons.alternate_email,
            title: 'E-posta',
            subtitle: _email?.isNotEmpty == true
                ? _email!
                : (_isGuest ? 'Misafir hesap' : 'Bagli degil'),
            onTap: null,
          ),
          if (!widget.offlineMode)
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }
}
