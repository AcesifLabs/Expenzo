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
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.dismissibleKey,
    this.onDismissed,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    Widget inner = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
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
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            PhosphorIcons.trash(PhosphorIconsStyle.regular),
            color: Colors.white,
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
