import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

/// Skeleton matching [BudgetProgressCard] layout — title, amount, progress bar.
class BudgetListSkeleton extends StatelessWidget {
  final int itemCount;

  const BudgetListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox.textLine(width: 140, height: 16),
                      ShimmerBox.circle(size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Amount line
                  ShimmerBox.textLine(width: 120, height: 14),
                  const SizedBox(height: 12),
                  // Progress bar
                  ShimmerBox.rectangle(
                    width: double.infinity,
                    height: 8,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 4),
                  // Sub-text
                  ShimmerBox.textLine(width: 150, height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
