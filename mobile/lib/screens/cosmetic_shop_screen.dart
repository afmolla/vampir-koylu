import 'package:flutter/material.dart';

import '../services/profile_service.dart';

class CosmeticShopScreen extends StatefulWidget {
  const CosmeticShopScreen({super.key, this.bundle});

  final Map<String, dynamic>? bundle;

  @override
  State<CosmeticShopScreen> createState() => _CosmeticShopScreenState();
}

class _CosmeticShopScreenState extends State<CosmeticShopScreen> {
  final _api = ProfileService();
  late Map<String, dynamic>? _bundle;

  @override
  void initState() {
    super.initState();
    _bundle = widget.bundle;
  }

  String _label(String id) {
    if (id.contains('skin')) return 'Vampir skin';
    if (id.contains('blood')) return 'Kanlı efekt';
    if (id.contains('graveyard')) return 'Mezarlık tema';
    if (id.contains('frame')) return 'Profil çerçevesi';
    if (id.contains('death')) return 'Ölüm animasyonu';
    return id;
  }

  String? _slotFor(String id) {
    if (id.contains('skin')) return 'skin';
    if (id.contains('frame')) return 'frame';
    if (id.contains('graveyard') || id.contains('theme')) return 'theme';
    if (id.contains('blood') || id.contains('fx')) return 'effect';
    if (id.contains('death')) return 'death_anim';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _bundle?['catalog'] as List<dynamic>? ?? [];
    final owned = (_bundle?['ownedCosmetics'] as List<dynamic>? ?? [])
        .cast<String>()
        .toSet();
    final profile = _bundle?['profile'] as Map<String, dynamic>? ?? {};
    final coins = profile['coins'] as int? ?? 0;
    final equipped = {
      'skin': profile['equippedSkin'],
      'frame': profile['equippedFrame'],
      'theme': profile['equippedTheme'],
      'effect': profile['equippedEffect'],
      'death_anim': profile['equippedDeathAnim'],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Kozmetik Mağaza')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: catalog.length,
        itemBuilder: (context, i) {
          final item = catalog[i] as Map<String, dynamic>;
          final id = item['id'] as String? ?? '';
          final price = item['price'] as int? ?? 0;
          final has = owned.contains(id);
          final slot = _slotFor(id);
          final isEquipped = slot != null && equipped[slot] == id;

          return Card(
            child: ListTile(
              title: Text(_label(id)),
              subtitle: Text(
                isEquipped
                    ? 'Kuşanıldı'
                    : 'Sadece görünüm — güç bonusu yok',
              ),
              trailing: has
                  ? (slot != null
                      ? FilledButton.tonal(
                          onPressed: isEquipped
                              ? null
                              : () async {
                                  try {
                                    final r = await _api.equipCosmetic(slot, id);
                                    setState(() => _bundle =
                                        r['bundle'] as Map<String, dynamic>?);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('$e')),
                                      );
                                    }
                                  }
                                },
                          child: Text(isEquipped ? 'Aktif' : 'Kuşan'),
                        )
                      : const Text('Sahip'))
                  : FilledButton(
                      onPressed: coins >= price
                          ? () async {
                              try {
                                final r = await _api.purchaseCosmetic(id);
                                setState(() =>
                                    _bundle = r['bundle'] as Map<String, dynamic>?);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$e')),
                                  );
                                }
                              }
                            }
                          : null,
                      child: Text('$price'),
                    ),
            ),
          );
        },
      ),
    );
  }
}
