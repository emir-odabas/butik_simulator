import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../atelier_colors.dart';

/// Wraps form content (product/campaign/coupon forms) with the "index
/// card being filled out" treatment: an underline `InputDecorationTheme`
/// (writing on ruled paper, not a filled Material box) and a small
/// paperclip accent instead of a plain grey drag-handle bar.
///
/// Only re-themes [InputDecorationTheme] — every other visual (buttons,
/// switches, dialogs opened from within) keeps using the app's normal
/// theme, so this stays a small, contained change rather than a second
/// parallel theme system.
///
/// Expects to be given a bounded height (e.g. the builder of a
/// [DraggableScrollableSheet]) — its content area expands to fill it so
/// the child's own scroll view works normally.
class ClipboardSheet extends StatelessWidget {
  const ClipboardSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    final underline = theme.inputDecorationTheme.copyWith(
      filled: false,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      border: UnderlineInputBorder(borderSide: BorderSide(color: atelier.hairline)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: atelier.hairline)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: atelier.seal, width: 1.6)),
      errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: atelier.error)),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(color: atelier.inkMuted),
      helperStyle: theme.textTheme.bodySmall,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: atelier.paperSurface,
            border: Border(top: BorderSide(color: atelier.hairline)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(width: 32, height: 3, color: atelier.hairline),
              ),
              Expanded(
                child: Theme(
                  data: theme.copyWith(inputDecorationTheme: underline),
                  child: child,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -13,
          left: 26,
          child: Transform.rotate(
            angle: -0.55,
            child: Icon(Icons.attach_file, size: 32, color: atelier.inkMuted),
          ),
        ),
      ],
    );
  }
}
