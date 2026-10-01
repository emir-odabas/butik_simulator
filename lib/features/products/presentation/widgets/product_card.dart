import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';
import '../../../../data/models/product.dart';

/// A single product row in the catalog list: image thumbnail, name,
/// category, price (with discount struck through when present), and
/// status badges (new/featured/best-seller/out-of-stock/inactive).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Hero(
                    tag: 'product-admin-${product.id}',
                    child: _ProductThumbnail(url: product.primaryImage),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.category,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        if (product.hasDiscount) ...[
                          Text(
                            Money.format(product.price),
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            Money.format(product.discountPrice!),
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: theme.colorScheme.primary),
                          ),
                        ] else
                          Text(
                            Money.format(product.price),
                            style: theme.textTheme.titleSmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (product.isOutOfStock)
                          const _Badge(label: 'Stok Yok', color: Colors.red)
                        else
                          _Badge(
                            label: '${product.stock} adet',
                            color: theme.colorScheme.outline,
                          ),
                        if (!product.isActive)
                          const _Badge(label: 'Satışta Değil', color: Colors.grey),
                        if (product.isNew)
                          const _Badge(label: 'Yeni', color: Colors.blue),
                        if (product.isFeatured)
                          const _Badge(label: 'Öne Çıkan', color: Colors.purple),
                        if (product.isBestSeller)
                          const _Badge(label: 'Çok Satan', color: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (url == null || url!.isEmpty) {
      return _placeholder(theme);
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(theme, loading: true);
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(theme, broken: true),
    );
  }

  Widget _placeholder(ThemeData theme, {bool loading = false, bool broken = false}) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              broken ? Icons.broken_image_outlined : Icons.image_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
