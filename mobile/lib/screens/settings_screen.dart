import 'package:flutter/material.dart';

/// Profil ayarları — Faz 2'de şifre, avatar, e-posta tamamlanacak.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil ayarları')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Şifre değiştir'),
            subtitle: Text('v0.2.12 — e-posta hesabı gerekli'),
            enabled: false,
          ),
          ListTile(
            leading: Icon(Icons.account_circle_outlined),
            title: Text('Profil fotoğrafı'),
            subtitle: Text('v0.2.12 — galeri / kamera'),
            enabled: false,
          ),
          ListTile(
            leading: Icon(Icons.alternate_email),
            title: Text('E-posta bağla'),
            subtitle: Text('Şifremi unuttum için gerekli'),
            enabled: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.g_mobiledata),
            title: Text('Google ile giriş'),
            subtitle: Text('Faz 2 — yakında'),
            enabled: false,
          ),
          ListTile(
            leading: Icon(Icons.facebook),
            title: Text('Facebook ile giriş'),
            subtitle: Text('Faz 2 — yakında'),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
