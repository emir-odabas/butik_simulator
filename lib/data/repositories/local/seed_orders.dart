import '../../models/order.dart';
import '../../models/order_status.dart';

List<Order> buildSeedOrders() {
  final now = DateTime.now();
  DateTime hoursAgo(int h) => now.subtract(Duration(hours: h));

  return [
    Order(
      id: 'seed-order-1',
      orderNumber: '#A1B2',
      customerId: 'cust-elif',
      customerName: 'Elif',
      items: const [
        OrderItem(productId: 'seed-1', productName: 'Krem Keten Elbise', unitPrice: 690, quantity: 1),
      ],
      status: OrderStatus.newOrder,
      createdAt: hoursAgo(2),
    ),
    Order(
      id: 'seed-order-2',
      orderNumber: '#C3D4',
      customerId: 'cust-ece',
      customerName: 'Ece',
      items: const [
        OrderItem(productId: 'seed-2', productName: 'Siyah Blazer Ceket', unitPrice: 1250, quantity: 1),
        OrderItem(productId: 'seed-8', productName: 'İnci Detaylı Küpe', unitPrice: 210, quantity: 2),
      ],
      status: OrderStatus.shipped,
      createdAt: hoursAgo(28),
    ),
    Order(
      id: 'seed-order-3',
      orderNumber: '#E5F6',
      customerId: 'cust-zeynep',
      customerName: 'Zeynep',
      items: const [
        OrderItem(productId: 'seed-6', productName: 'Yüksek Bel Kot Pantolon', unitPrice: 710, quantity: 1),
      ],
      status: OrderStatus.delivered,
      createdAt: hoursAgo(96),
      deliveredAt: hoursAgo(70),
      rewardGranted: true,
    ),
  ];
}
