import 'package:flutter/material.dart';

/// Reusable badge with optional leading icon.
/// Supports small and normal sizes.
class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final AppBadgeSize size;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.size = AppBadgeSize.normal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = (color ?? theme.colorScheme.primary).withAlpha(30);
    final textColor = color ?? theme.colorScheme.primary;

    final (
      double hPad,
      double vPad,
      double fontSize,
      double iconSize,
    ) = switch (size) {
      AppBadgeSize.small => (6.0, 2.0, 10.0, 12.0),
      AppBadgeSize.normal => (8.0, 4.0, 12.0, 14.0),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        ],
      ),
    );
  }
}

enum AppBadgeSize { small, normal }
