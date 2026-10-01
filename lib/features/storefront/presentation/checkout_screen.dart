import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../../cart/application/cart_provider.dart';
import '../../customers/application/customer_providers.dart';
import '../../notifications/application/notification_providers.dart';
import '../../../data/models/app_notification.dart';
import '../../orders/application/order_providers.dart';

/// Checkout is entirely simulated: no real payment form, no card
/// details, no real payment provider. Confirming just creates a virtual
/// [Order] and clears the cart.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedCustomerId;
  bool _isPlacingOrder = false;

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty || _selectedCustomerId == null) return;

    setState(() => _isPlacingOrder = true);

    final customers = ref.read(customersProvider).valueOrNull ?? [];
    final customer = customers.firstWhere((c) => c.id == _selectedCustomerId);

    final order = Order(
      id: IdGenerator.generate(),
      orderNumber: '#${IdGenerator.generate().substring(0, 4).toUpperCase()}',
      customerId: customer.id,
      customerName: customer.name,
      items: [
        for (final item in cart)
          OrderItem(
            productId: item.productId,
            productName: item.productName,
            unitPrice: item.unitPrice,
            quantity: item.quantity,
          ),
      ],
      status: OrderStatus.newOrder,
      createdAt: DateTime.now(),
    );

    await ref.read(ordersProvider.notifier).addOrder(order);
    await ref.read(customersProvider.notifier).recordSpend(customer.id, order.totalPrice);
    ref.read(cartProvider.notifier).clear();
    await ref.read(notificationsProvider.notifier).add(
          NotificationType.newOrder,
          '🔔 Yeni sipariş',
          '${customer.name}, ${order.orderNumber} numaralı siparişi verdi.',
        );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);
    HapticFeedback.mediumImpact();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Sipariş oluşturuldu!'),
        content: Text(
          '${order.orderNumber} numaralı sipariş ${customer.name} adına oluşturuldu. '
          'Bu tamamen simülasyon amaçlıdır; gerçek bir ödeme veya kargo işlemi yapılmamıştır.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final customersAsync = ref.watch(customersProvider);
    final total = cart.fold<double>(0, (sum, i) => sum + i.lineTotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Siparişi Onayla')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Bu bir simülasyondur. Gerçek ödeme alınmaz, gerçek kargo yapılmaz.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Sipariş kimin adına oluşturulsun?',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          customersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text('Müşteriler yüklenemedi: $error'),
            data: (customers) => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final customer in customers)
                  ChoiceChip(
                    label: Text(customer.name),
                    selected: _selectedCustomerId == customer.id,
                    onSelected: (_) => setState(() => _selectedCustomerId = customer.id),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Sipariş Özeti', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          for (final item in cart)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text('${item.productName} × ${item.quantity}')),
                  Text(Money.format(item.lineTotal)),
                ],
              ),
            ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Toplam', style: Theme.of(context).textTheme.titleMedium),
              Text(Money.format(total), style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: (_selectedCustomerId != null && !_isPlacingOrder) ? _placeOrder : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: _isPlacingOrder
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Siparişi Oluştur'),
            ),
          ),
        ],
      ),
    );
  }
}
