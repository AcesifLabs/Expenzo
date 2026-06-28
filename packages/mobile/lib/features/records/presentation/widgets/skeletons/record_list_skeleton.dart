import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class ExpenseListSkeleton extends StatelessWidget {
  final int itemCount;

  const ExpenseListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ShimmerBox.rectangle(width: 48, height: 48, borderRadius: 8),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox.textLine(height: 14),
                        const SizedBox(height: 6),
                        ShimmerBox.textLine(width: 100, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  ShimmerBox.textLine(width: 70, height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
