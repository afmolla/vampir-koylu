import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Google Play turnuva giriş ücreti (consumable).
class BillingService {
  BillingService() {
    _purchaseSub = _iap.purchaseStream.listen(_onPurchaseUpdate);
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  Completer<PurchaseDetails>? _pendingPurchase;

  Future<bool> init() async {
    return _iap.isAvailable();
  }

  Future<PurchaseDetails> buyConsumable(String productId) async {
    final response = await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('Ürün bulunamadı: $productId');
    }
    if (response.productDetails.isEmpty) {
      throw Exception('Play Console ürünü tanımlı değil');
    }

    final product = response.productDetails.first;
    _pendingPurchase = Completer<PurchaseDetails>();

    final param = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: param);

    return _pendingPurchase!.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () => throw Exception('Ödeme zaman aşımı'),
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _pendingPurchase?.complete(p);
        _pendingPurchase = null;
      } else if (p.status == PurchaseStatus.error) {
        _pendingPurchase?.completeError(
          Exception(p.error?.message ?? 'purchase_error'),
        );
        _pendingPurchase = null;
      } else if (p.status == PurchaseStatus.canceled) {
        _pendingPurchase?.completeError(Exception('canceled'));
        _pendingPurchase = null;
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
  }
}
