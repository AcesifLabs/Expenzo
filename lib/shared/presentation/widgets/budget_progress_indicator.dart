import 'package:flutter/material.dart';

/// A colored progress bar for budget utilization.
///
/// Colors:
/// - Green (< 80%): spending is under control
/// - Orange (80–100%): approaching limit
/// - Red (> 100%): over budget
class BudgetProgressIndicator extends StatelessWidget {
  final double percentage;
  final double height;

  const BudgetProgressIndicator({
    super.key,
    required this.percentage,
    this.height = 8,
  });

  Color _color() {
    if (percentage > 100) return const Color(0xFFFF3B30); // red
    if (percentage >= 80) return const Color(0xFFFF9F0A); // orange
    return const Color(0xFF34C759); // green
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: (percentage / 100).clamp(0.0, 1.0),
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
        color: _color(),
        minHeight: height,
      ),
    );
  }
}
