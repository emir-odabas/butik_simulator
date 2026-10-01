/// The lifecycle a simulated order moves through.
enum OrderStatus {
  newOrder,
  preparing,
  shipped,
  delivered,
  cancelled;

  String get label => switch (this) {
        OrderStatus.newOrder => 'Yeni Sipariş',
        OrderStatus.preparing => 'Hazırlanıyor',
        OrderStatus.shipped => 'Kargoya Verildi',
        OrderStatus.delivered => 'Teslim Edildi',
        OrderStatus.cancelled => 'İptal Edildi',
      };

  static OrderStatus fromName(String name) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => OrderStatus.newOrder,
    );
  }
}
