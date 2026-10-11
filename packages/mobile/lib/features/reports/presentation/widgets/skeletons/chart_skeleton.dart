import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});

  Widget _buildChipRow() {
    final chip = ShimmerBox.rectangle(
      width: 80,
      height: 32,
      borderRadius: AppSpacing.radiusControl,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        chip,
        const SizedBox(width: AppSpacing.sm),
        chip,
        const SizedBox(width: AppSpacing.sm),
        chip,
      ],
    );
  }

  Widget _buildYAxis() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        5,
        (_) => ShimmerBox.textLine(width: 40, height: 10),
      ),
    );
  }

  Widget _buildChartArea() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildYAxis(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ShimmerBox.rectangle(
              width: double.infinity,
              height: double.infinity,
              borderRadius: AppSpacing.radiusControl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXAxis() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (_) => ShimmerBox.textLine(width: 30, height: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildChipRow(),
            const SizedBox(height: AppSpacing.md),
            _buildChartArea(),
            const SizedBox(height: AppSpacing.sm),
            _buildXAxis(),
          ],
        ),
      ),
    );
  }
}
