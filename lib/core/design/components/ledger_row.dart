import 'package:flutter/material.dart';

import '../atelier_colors.dart';

/// A single ruled line in a table-like list — no card, no border box,
/// just content with a hairline rule below it, the way lines are ruled
/// on real ledger paper. Used for the order list now; coupons and
/// statistics reuse the same row in a later phase.
class LedgerRow extends StatelessWidget {
  const LedgerRow({
    super.key,
    required this.child,
    this.onTap,
    this.showDivider = true,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;
    final content = Padding(padding: padding, child: child);

    return Column(
      children: [
        onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: content),
              )
            : content,
        if (showDivider) Divider(color: atelier.hairline, height: 1),
      ],
    );
  }
}
