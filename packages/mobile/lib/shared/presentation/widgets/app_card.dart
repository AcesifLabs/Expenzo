import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
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

    final localBorderColor = borderColor;
    final effectiveBorder = localBorderColor != null
        ? Border.all(color: localBorderColor, width: 1.5)
        : null;
    final localPadding = padding;
    final paddedChild = localPadding != null
        ? Padding(padding: localPadding, child: child)
        : child;

    final inner = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: effectiveBorder,
      ),
      clipBehavior: clipBehavior,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: paddedChild,
        ),
      ),
    );

    final localMargin = margin;
    if (localMargin != null) {
      return Padding(padding: localMargin, child: inner);
    }

    return inner;
  }
}
