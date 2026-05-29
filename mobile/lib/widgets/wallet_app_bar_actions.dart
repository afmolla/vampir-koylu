import 'package:flutter/material.dart';

import '../services/engagement_service.dart';
import '../services/wallet_refresh.dart';
import 'coins_balance_chip.dart';

/// AppBar sag ust — coin ve bakiye (sunucudan yukler veya disaridan verilir).
class WalletAppBarActions extends StatefulWidget {
  const WalletAppBarActions({
    super.key,
    this.coins,
    this.balanceTry,
    this.refreshKey,
  });

  final int? coins;
  final int? balanceTry;
  /// Degisince yeniden yukler (ornegin odadan donunce).
  final Object? refreshKey;

  @override
  State<WalletAppBarActions> createState() => _WalletAppBarActionsState();
}

class _WalletAppBarActionsState extends State<WalletAppBarActions> {
  final _engagement = EngagementService();
  int _coins = 0;
  int _balance = 0;
  bool _loading = true;

  VoidCallback? _walletListener;

  @override
  void initState() {
    super.initState();
    _walletListener = () {
      final w = WalletRefresh.notifier.value;
      if (w != null && mounted) {
        setState(() {
          _coins = w['coins'] ?? _coins;
          _balance = w['balance'] ?? _balance;
          _loading = false;
        });
      }
    };
    WalletRefresh.notifier.addListener(_walletListener!);
    _applyPropsOrLoad();
  }

  @override
  void didUpdateWidget(covariant WalletAppBarActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coins != oldWidget.coins ||
        widget.balanceTry != oldWidget.balanceTry ||
        widget.refreshKey != oldWidget.refreshKey) {
      _applyPropsOrLoad();
    }
  }

  @override
  void dispose() {
    if (_walletListener != null) {
      WalletRefresh.notifier.removeListener(_walletListener!);
    }
    _engagement.dispose();
    super.dispose();
  }

  void _applyPropsOrLoad() {
    if (widget.coins != null && widget.balanceTry != null) {
      setState(() {
        _coins = widget.coins!;
        _balance = widget.balanceTry!;
        _loading = false;
      });
      return;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final home = await _engagement.fetchHome();
      final profile = home['profile'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _coins = profile['coins'] as int? ?? 0;
        _balance = profile['balance'] as int? ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoinsBalanceChip(
      coins: widget.coins ?? _coins,
      balanceTry: widget.balanceTry ?? _balance,
      loading: _loading,
    );
  }
}
