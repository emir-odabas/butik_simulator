import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/product.dart';
import 'cart_item.dart';

/// The customer-side shopping cart.
///
/// Kept as in-memory session state on purpose: the cart belongs to
/// whichever virtual customer is "browsing" the storefront preview
/// right now, not to the store owner's persisted data, so it resets
/// each time the storefront preview is reopened.
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  double get totalPrice => state.fold(0, (sum, item) => sum + item.lineTotal);

  int get totalItemCount => state.fold(0, (sum, item) => sum + item.quantity);

  void addProduct(Product product) {
    final existingIndex = state.indexWhere((i) => i.productId == product.id);
    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == existingIndex) existing.copyWith(quantity: existing.quantity + 1) else state[i],
      ];
    } else {
      state = [
        ...state,
        CartItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.hasDiscount ? product.discountPrice! : product.price,
          imageUrl: product.primaryImage,
          quantity: 1,
        ),
      ];
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId) item.copyWith(quantity: quantity) else item,
    ];
  }

  void removeProduct(String productId) {
    state = state.where((i) => i.productId != productId).toList();
  }

  void clear() => state = const [];
}
