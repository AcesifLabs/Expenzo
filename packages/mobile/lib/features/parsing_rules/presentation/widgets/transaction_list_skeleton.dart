import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class TransactionListSkeleton extends StatelessWidget {
  final int itemCount;

  const TransactionListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const TransactionCardSkeleton();
        },
      ),
    );
  }
}

class TransactionCardSkeleton extends StatelessWidget {
  const TransactionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.smd),
        child: Row(
          children: [
            ShimmerBox.rectangle(
              width: 24,
              height: 24,
              borderRadius: AppSpacing.radiusPill,
            ),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShimmerBox.textLine(width: 80, height: 18),
                      const SizedBox(width: AppSpacing.sm),
                      ShimmerBox.circle(size: 16),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  ShimmerBox.textLine(height: 14),
                  const SizedBox(height: AppSpacing.xs),
                  ShimmerBox.textLine(width: 200, height: 12),
                  const SizedBox(height: AppSpacing.sm),

                  ShimmerBox.rectangle(
                    width: 60,
                    height: 18,
                    borderRadius: AppSpacing.radiusPill,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
