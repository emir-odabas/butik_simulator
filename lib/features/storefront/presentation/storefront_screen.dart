import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/product.dart';
import '../../cart/application/cart_provider.dart';
import '../../products/application/product_providers.dart';
import '../../store/application/store_providers.dart';
import 'cart_screen.dart';
import 'widgets/storefront_product_card.dart';
import 'widgets/storefront_product_sheet.dart';

/// "Mağazayı Görüntüle": shows the boutique the way a customer sees it —
/// active products only, add-to-cart, and a cart badge leading to
/// checkout. Pushed as its own full-screen route from the Store tab so
/// it stays clearly separate from the owner's admin views.
class StorefrontScreen extends ConsumerWidget {
  const StorefrontScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(storeProfileProvider);
    final productsAsync = ref.watch(productsProvider);
    final cartCount = ref.watch(cartProvider.select(
      (items) => items.fold<int>(0, (sum, i) => sum + i.quantity),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(profileAsync.valueOrNull?.name ?? 'Mağaza'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ürünler yüklenemedi: $error')),
        data: (products) {
          final active = products.where((p) => p.isActive && !p.isOutOfStock).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (active.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: EmptyState(
                icon: Icons.storefront_outlined,
                title: 'Vitrin şu anda boş',
                message: 'Satışa açık ürün eklendiğinde burada görünecek.',
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _StorefrontHeader(
              description: profileAsync.valueOrNull?.description ?? '',
              products: active,
            ),
          );
        },
      ),
    );
  }
}

class _StorefrontHeader extends StatelessWidget {
  const _StorefrontHeader({required this.description, required this.products});

  final String description;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (description.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.68,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = products[index];
              return StorefrontProductCard(
                product: product,
                onTap: () => showStorefrontProductSheet(context, product),
              );
            },
            childCount: products.length,
          ),
        ),
      ],
    );
  }
}
