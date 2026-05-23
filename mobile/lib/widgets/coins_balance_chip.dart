import 'package:flutter/material.dart';

/// Sag ust: coin + TL bakiye.
class CoinsBalanceChip extends StatelessWidget {
  const CoinsBalanceChip({
    super.key,
    required this.coins,
    this.balanceTry = 0,
    this.loading = false,
  });

  final int coins;
  final int balanceTry;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
          const SizedBox(width: 3),
          if (loading)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              '$coins',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          const SizedBox(width: 8),
          Container(width: 1, height: 14, color: Colors.white24),
          const SizedBox(width: 8),
          const Icon(Icons.account_balance_wallet_outlined,
              color: Colors.lightGreenAccent, size: 16),
          const SizedBox(width: 3),
          Text(
            '$balanceTry ₺',
            style: const TextStyle(
              color: Colors.lightGreenAccent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
