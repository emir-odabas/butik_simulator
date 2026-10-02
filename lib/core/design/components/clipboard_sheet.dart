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
/// Set [expand] to `true` when given a bounded height to fill (e.g. the
/// builder of a [DraggableScrollableSheet], where the child is itself a
/// scroll view) — the default `false` instead sizes to the child's own
/// content, for short forms shown as an ordinary auto-sizing bottom
/// sheet (e.g. in a [SingleChildScrollView]).
class ClipboardSheet extends StatelessWidget {
  const ClipboardSheet({super.key, required this.child, this.expand = false});

  final Widget child;
  final bool expand;

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

    final themedChild = Theme(
      data: theme.copyWith(inputDecorationTheme: underline),
      child: child,
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
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Container(width: 32, height: 3, color: atelier.hairline),
              ),
              expand ? Expanded(child: themedChild) : themedChild,
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
