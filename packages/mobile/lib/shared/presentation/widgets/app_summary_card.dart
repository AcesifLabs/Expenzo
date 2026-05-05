import 'package:flutter/material.dart';

/// Slot-based dark summary card with title, large value, and optional bottom child.
///
/// Example usage:
/// ```dart
/// AppSummaryCard(
///   title: 'Total Balance',
///   value: '\$1,234.56',
///   bottomChild: Row(children: [...incomeRow, ...expenseRow]),
/// )
/// ```
class AppSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? bottomChild;

  const AppSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.bottomChild,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withAlpha(160),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          if (bottomChild != null) ...[
            const SizedBox(height: 16),
            bottomChild!,
          ],
        ],
      ),
    );
  }
}
