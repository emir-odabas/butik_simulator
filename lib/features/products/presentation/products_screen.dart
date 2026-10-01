import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/product_categories.dart';
import '../../../core/design/components/ledger_page.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/product_providers.dart';
import 'product_detail_sheet.dart';
import 'product_form_sheet.dart';
import 'widgets/category_tab_row.dart';
import 'widgets/product_polaroid.dart';

/// Product catalog as a "card drawer": Polaroids at a light, stable
/// per-item tilt in a loosely staggered grid, not a uniform Material
/// list. Category filter reads as notebook folder-divider labels.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ürünler')),
      body: LedgerPage(
        child: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('Ürünler yüklenemedi: $error'),
            ),
          ),
          data: (products) {
            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: EmptyState(
                  icon: Icons.checkroom_outlined,
                  title: 'Henüz ürün eklemedin',
                  message: 'İlk ürününü ekleyerek mağazanı aç!',
                  actionLabel: 'Ürün Ekle',
                  onAction: () => showProductFormSheet(context),
                ),
              );
            }

            final presentCategories = [
              for (final c in ProductCategories.defaults)
                if (products.any((p) => p.category == c)) c,
            ];

            final filtered = _category == null
                ? products
                : products.where((p) => p.category == _category).toList();
            final sorted = [...filtered]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                if (presentCategories.length > 1)
                  CategoryTabRow(
                    categories: presentCategories,
                    selected: _category,
                    onSelected: (c) => setState(() => _category = c),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: sorted.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: Text(
                              'Bu kategoride ürün yok.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            AppSpacing.xxl,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.md,
                            crossAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.62,
                          ),
                          itemCount: sorted.length,
                          itemBuilder: (context, index) {
                            final product = sorted[index];
                            // A light stagger — odd cards sit a little
                            // lower — so the grid reads as a loosely
                            // scattered drawer of photos, not a rigid
                            // table, without true masonry layout.
                            final isOdd = index.isOdd;
                            return Padding(
                              padding: EdgeInsets.only(
                                top: isOdd ? 16 : 0,
                                bottom: isOdd ? 0 : 16,
                              ),
                              child: ProductPolaroid(
                                product: product,
                                onTap: () => showProductDetailSheet(context, product),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
