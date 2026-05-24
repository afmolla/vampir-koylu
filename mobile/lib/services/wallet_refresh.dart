import 'package:flutter/foundation.dart';

/// Sunucu `wallet:update` olaylari — AppBar bakiye chip.
class WalletRefresh {
  WalletRefresh._();

  static final ValueNotifier<Map<String, int>?> notifier =
      ValueNotifier<Map<String, int>?>(null);

  static void apply(Map<String, dynamic> data) {
    final coins = data['coins'];
    final balance = data['balance'];
    if (coins is! num && balance is! num) return;
    notifier.value = {
      'coins': (coins as num?)?.toInt() ?? 0,
      'balance': (balance as num?)?.toInt() ?? 0,
    };
  }
}
