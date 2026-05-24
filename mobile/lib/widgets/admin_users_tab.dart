import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/admin_service.dart';

/// Yönetici: kayıtlı üyeler ve misafirler listesi.
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _api = AdminService();
  final _searchController = TextEditingController();
  String _filter = 'registered';
  List<dynamic> _users = [];
  int _total = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchUsers(
        filter: _filter,
        search: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _users = data['users'] as List<dynamic>? ?? [];
        _total = data['total'] as int? ?? _users.length;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.adminSearchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _load,
              ),
            ),
            onSubmitted: (_) => _load(),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ChoiceChip(
                label: Text(l10n.adminFilterRegistered),
                selected: _filter == 'registered',
                onSelected: (_) {
                  setState(() => _filter = 'registered');
                  _load();
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(l10n.adminFilterGuest),
                selected: _filter == 'guest',
                onSelected: (_) {
                  setState(() => _filter = 'guest');
                  _load();
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(l10n.adminFilterAll),
                selected: _filter == 'all',
                onSelected: (_) {
                  setState(() => _filter = 'all');
                  _load();
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.adminTotalUsers(_total),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    )
                  : _users.isEmpty
                      ? Center(child: Text(l10n.adminNoUsers))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _users.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final u =
                                  _users[i] as Map<String, dynamic>;
                              final isGuest = u['isGuest'] == true;
                              final email = u['email'] as String?;
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    _initial(u['nick'] as String?),
                                  ),
                                ),
                                title: Text(u['nick'] as String? ?? '?'),
                                subtitle: Text(
                                  [
                                    if (isGuest) l10n.adminBadgeGuest else l10n.adminBadgeMember,
                                    if (email != null && email.isNotEmpty)
                                      email,
                                    '${u['coins'] ?? 0} coin · ${u['balance'] ?? 0} ₺',
                                  ].join(' · '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.monetization_on_outlined),
                                      tooltip: 'Coin',
                                      onPressed: () => _adjustCoins(
                                        u['id'] as String? ?? '',
                                        u['nick'] as String? ?? '?',
                                      ),
                                    ),
                                    Text(
                                      _formatDate(u['createdAt'] as String?),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.length < 10) return '';
    return iso.substring(0, 10);
  }

  Future<void> _adjustCoins(String userId, String nick) async {
    if (userId.isEmpty) return;
    final deltaCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Coin — $nick'),
        content: TextField(
          controller: deltaCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ekle (+) veya çıkar (-)',
            hintText: 'ör. 100 veya -50',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final delta = int.tryParse(deltaCtrl.text.trim());
    if (delta == null || delta == 0) return;
    try {
      await _api.adjustCoins(userId: userId, delta: delta);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coin güncellendi ($delta)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  String _initial(String? nick) {
    final n = nick?.trim() ?? '';
    if (n.isEmpty) return '?';
    return n[0].toUpperCase();
  }
}
