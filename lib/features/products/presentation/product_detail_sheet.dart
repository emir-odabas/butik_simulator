import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/atelier_colors.dart';
import '../../../core/design/atelier_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/product.dart';
import '../application/product_providers.dart';
import 'product_form_sheet.dart';

Future<void> showProductDetailSheet(BuildContext context, Product product) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _ProductDetailSheet(product: product),
  );
}

/// The product's "file page": the Polaroid photo with a price tag
/// hanging off its corner, the story (name/category/description) below
/// it, then its numbers as ledger rows, then actions as ledger rows
/// too — deliberately not another stack of `OutlinedButton`s.
class _ProductDetailSheet extends ConsumerWidget {
  const _ProductDetailSheet({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md, right: AppSpacing.md),
                child: _PhotoWithPriceTag(product: product),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(product.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              product.category.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: atelier.inkMuted,
                letterSpacing: 1.6,
              ),
            ),
            if (product.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Not: ',
                      style: AtelierTypography.annotation(color: atelier.seal, fontSize: 20),
                    ),
                    TextSpan(text: product.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _LedgerStat(
              icon: Icons.visibility_outlined,
              label: 'Görüntülenme',
              value: '${product.viewCount}',
            ),
            _LedgerStat(
              icon: Icons.favorite_outline,
              label: 'Favori',
              value: '${product.favoriteCount}',
            ),
            _LedgerStat(
              icon: Icons.shopping_bag_outlined,
              label: 'Satış',
              value: '${product.salesCount}',
              showDivider: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ActionRow(
              icon: Icons.edit_outlined,
              label: 'Düzenle',
              onTap: () {
                Navigator.of(context).pop();
                showProductFormSheet(context, product: product);
              },
            ),
            _ActionRow(
              icon: product.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              label: product.isActive ? 'Satıştan Kaldır' : 'Satışa Aç',
              onTap: () {
                ref.read(productsProvider.notifier).toggleActive(product);
                Navigator.of(context).pop();
              },
            ),
            _ActionRow(
              icon: Icons.delete_outline,
              label: 'Sil',
              color: atelier.error,
              showDivider: false,
              onTap: () => _confirmDelete(context, ref),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü sil'),
        content: Text('"${product.name}" ürününü silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(productsProvider.notifier).deleteProduct(product.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

/// The Polaroid-framed photo with a small price tag "hanging" off its
/// top-right corner by a thin string — a plain rotated rectangle and a
/// thin line, no [CustomPainter] needed for this.
class _PhotoWithPriceTag extends StatelessWidget {
  const _PhotoWithPriceTag({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          elevation: 3,
          shadowColor: atelier.ink,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Hero(
              tag: 'product-admin-${product.id}',
              child: SizedBox(
                width: 220,
                height: 220,
                child: product.primaryImage != null
                    ? Image.network(
                        product.primaryImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: atelier.paperSurface,
                          child: Icon(Icons.broken_image_outlined, color: atelier.inkMuted, size: 36),
                        ),
                      )
                    : ColoredBox(
                        color: atelier.paperSurface,
                        child: Icon(Icons.image_outlined, color: atelier.inkMuted, size: 36),
                      ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -18,
          right: 4,
          child: Column(
            children: [
              Container(width: 1.4, height: 18, color: atelier.inkMuted),
              Transform.rotate(
                angle: 0.16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: atelier.paperSurface,
                    border: Border.all(color: atelier.hairline),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: -4,
                        top: -4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: atelier.paper,
                            shape: BoxShape.circle,
                            border: Border.all(color: atelier.hairline),
                          ),
                        ),
                      ),
                      if (product.hasDiscount)
                        Text(
                          Money.format(product.discountPrice!),
                          style: AtelierTypography.ledger(color: atelier.seal, fontSize: 15),
                        )
                      else
                        Text(
                          Money.format(product.price),
                          style: AtelierTypography.ledger(color: atelier.ink, fontSize: 15),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LedgerStat extends StatelessWidget {
  const _LedgerStat({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: atelier.ink),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
              Text(value, style: AtelierTypography.ledger(color: atelier.ink, fontSize: 15)),
            ],
          ),
        ),
        if (showDivider) Divider(color: atelier.hairline, height: 1),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    final effectiveColor = color ?? atelier.ink;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: effectiveColor),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(color: effectiveColor),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: atelier.inkMuted),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) Divider(color: atelier.hairline, height: 1),
      ],
    );
  }
}
