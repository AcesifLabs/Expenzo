import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class InsightsSkeleton extends StatelessWidget {
  final int itemCount;

  const InsightsSkeleton({super.key, this.itemCount = 4});

  Widget _buildSkeletonItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.smd),
      child: ListTile(
        leading: ShimmerBox.circle(size: 40),
        title: ShimmerBox.textLine(height: 14),
        subtitle: ShimmerBox.textLine(width: 100, height: 12),
        trailing: ShimmerBox.textLine(width: 70, height: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(itemCount, _buildSkeletonItem),
        ),
      ),
    );
  }
}
