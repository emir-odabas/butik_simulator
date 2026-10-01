/// A line in the customer-side shopping cart.
class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.imageUrl,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final String? imageUrl;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      productName: productName,
      unitPrice: unitPrice,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
