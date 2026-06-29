import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

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

  Widget _buildDismissibleBackground(ColorScheme colors, double radius) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(PiconsRegular.trash, color: colors.onSecondary),
    );
  }

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

    Widget inner = Container(
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

    final localDismissibleKey = dismissibleKey;
    final localOnDismissed = onDismissed;
    if (localDismissibleKey != null && localOnDismissed != null) {
      inner = Dismissible(
        key: localDismissibleKey,
        direction: DismissDirection.endToStart,
        onDismissed: (_) => localOnDismissed(),
        background: _buildDismissibleBackground(theme.colorScheme, radius),
        child: inner,
      );
    }

    final localMargin = margin;
    if (localMargin != null) {
      return Padding(padding: localMargin, child: inner);
    }

    return inner;
  }
}
