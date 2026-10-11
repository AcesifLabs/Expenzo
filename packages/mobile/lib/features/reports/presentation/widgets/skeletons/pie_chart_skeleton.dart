import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class PieChartSkeleton extends StatelessWidget {
  const PieChartSkeleton({super.key});

  Widget _buildLegendItem(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShimmerBox.circle(size: 12),
        const SizedBox(width: AppSpacing.xs),
        ShimmerBox.textLine(width: 60, height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Expanded(child: Center(child: ShimmerBox.circle(size: 200))),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(6, _buildLegendItem),
            ),
          ],
        ),
      ),
    );
  }
}
