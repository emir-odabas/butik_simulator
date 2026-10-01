import 'package:flutter/material.dart';

import '../../../../core/design/atelier_colors.dart';
import '../../../../core/design/atelier_typography.dart';
import '../../../../core/design/components/polaroid_card.dart';
import '../../../../core/utils/money.dart';
import '../../../../data/models/product.dart';

/// Product catalog card — a [PolaroidCard] captioned with name and
/// price, corner-tagged with whichever single status matters most
/// (out of stock > inactive > new > featured > best seller).
class ProductPolaroid extends StatelessWidget {
  const ProductPolaroid({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    String? tag;
    Color? tagColor;
    if (product.isOutOfStock) {
      tag = 'STOK YOK';
      tagColor = atelier.error;
    } else if (!product.isActive) {
      tag = 'PASİF';
      tagColor = atelier.inkMuted;
    } else if (product.isNew) {
      tag = 'YENİ';
      tagColor = atelier.seal;
    } else if (product.isFeatured) {
      tag = 'ÖNE ÇIKAN';
      tagColor = atelier.gold;
    } else if (product.isBestSeller) {
      tag = 'ÇOK SATAN';
      tagColor = atelier.thread;
    }

    return PolaroidCard(
      seedKey: product.id,
      imageUrl: product.primaryImage,
      dimmed: !product.isActive || product.isOutOfStock,
      cornerTag: tag,
      cornerTagColor: tagColor,
      onTap: onTap,
      caption: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(color: atelier.ink),
          ),
          const SizedBox(height: 2),
          if (product.hasDiscount)
            Row(
              children: [
                Text(
                  Money.format(product.price),
                  style: AtelierTypography.ledger(color: atelier.inkMuted, fontSize: 11)
                      .copyWith(decoration: TextDecoration.lineThrough),
                ),
                const SizedBox(width: 5),
                Text(
                  Money.format(product.discountPrice!),
                  style: AtelierTypography.ledger(color: atelier.seal, fontSize: 13),
                ),
              ],
            )
          else
            Text(
              Money.format(product.price),
              style: AtelierTypography.ledger(color: atelier.ink, fontSize: 13),
            ),
        ],
      ),
    );
  }
}
