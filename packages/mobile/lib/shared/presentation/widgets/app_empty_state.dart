import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'scrollable_center.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = actionLabel;

    return ScrollableCenter(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: colors.onSurfaceVariant),
          const SizedBox(height: AppSpacing.smd),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (label != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(onPressed: onAction, child: Text(label)),
          ],
        ],
      ),
    );
  }
}
