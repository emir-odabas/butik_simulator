import 'order_status.dart';

/// A single product line within an [Order]. Denormalizes the product
/// name/price at the time of purchase so the order stays accurate even
/// if the product is later edited or deleted from the catalog.
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}

/// A simulated customer order. Entirely virtual — no real payment,
/// shipping, or delivery happens anywhere in this app.
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.rewardGranted = false,
  });

  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;

  /// When the order first reached [OrderStatus.delivered]. Used by daily
  /// quests/achievements that care about "orders completed today".
  final DateTime? deliveredAt;

  /// Whether the virtual revenue/XP reward for completing this order has
  /// already been granted, so re-viewing a delivered order never grants
  /// it twice.
  final bool rewardGranted;

  double get totalPrice => items.fold(0, (sum, item) => sum + item.lineTotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({OrderStatus? status, DateTime? deliveredAt, bool? rewardGranted}) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      customerName: customerName,
      items: items,
      status: status ?? this.status,
      createdAt: createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      rewardGranted: rewardGranted ?? this.rewardGranted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'customerId': customerId,
        'customerName': customerName,
        'items': items.map((i) => i.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'rewardGranted': rewardGranted,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      items: (json['items'] as List)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.fromName(json['status'] as String? ?? 'newOrder'),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'] as String)
          : null,
      rewardGranted: json['rewardGranted'] as bool? ?? false,
    );
  }
}
