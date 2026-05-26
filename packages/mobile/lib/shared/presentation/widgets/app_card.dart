import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Standardized list card with optional dismissible swipe-to-delete.
///
/// Usage:
/// ```dart
/// AppCard(
///   onTap: () => ...,
///   dismissibleKey: Key('record_$id'),
///   onDismissed: () => ...,
///   child: Row(...),
/// )
/// ```
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Key? dismissibleKey;
  final VoidCallback? onDismissed;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.dismissibleKey,
    this.onDismissed,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius =
        borderRadius ??
        (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius
            .resolve(Directionality.of(context))
            .topLeft
            .x ??
        10.0;

    Widget inner = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
      ),
      clipBehavior: clipBehavior,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );

    if (dismissibleKey != null && onDismissed != null) {
      inner = Dismissible(
        key: dismissibleKey!,
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Icon(
            PhosphorIcons.trash(PhosphorIconsStyle.regular),
            color: theme.colorScheme.onSecondary,
          ),
        ),
        child: inner,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: inner);
    }

    return inner;
  }
}
