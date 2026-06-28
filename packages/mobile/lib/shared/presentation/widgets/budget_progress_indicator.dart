import 'package:flutter/material.dart';

class BudgetProgressIndicator extends StatelessWidget {
  final double percentage;
  final double height;

  const BudgetProgressIndicator({
    super.key,
    required this.percentage,
    this.height = 12,
  });

  Color _color(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (percentage > 100) return colors.error;
    if (percentage >= 80) {
      return const Color(0xFFFF9F0A);
    }
    return colors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (percentage / 100).clamp(0.0, 1.0),
      backgroundColor: Theme.of(context).colorScheme.onSurface.withAlpha(20),
      color: _color(context),
      minHeight: height,
    );
  }
}
