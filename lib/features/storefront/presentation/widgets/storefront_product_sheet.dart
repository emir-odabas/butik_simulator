import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';
import '../../../../data/models/product.dart';
import '../../../cart/application/cart_provider.dart';

Future<void> showStorefrontProductSheet(BuildContext context, Product product) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _StorefrontProductSheet(product: product),
  );
}

class _StorefrontProductSheet extends ConsumerWidget {
  const _StorefrontProductSheet({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              child: Hero(
                tag: 'product-storefront-${product.id}',
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: product.primaryImage != null
                      ? Image.network(
                          product.primaryImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined, size: 40),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_outlined, size: 40),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(product.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(product.category, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            if (product.hasDiscount)
              Row(
                children: [
                  Text(
                    Money.format(product.price),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    Money.format(product.discountPrice!),
                    style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
                  ),
                ],
              )
            else
              Text(Money.format(product.price), style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            if (product.description.isNotEmpty)
              Text(product.description, style: theme.textTheme.bodyMedium),
            if (product.sizes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                children: [for (final s in product.sizes) Chip(label: Text(s))],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(cartProvider.notifier).addProduct(product);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} sepete eklendi')),
                );
              },
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: const Text('Sepete Ekle'),
            ),
          ],
        );
      },
    );
  }
}
