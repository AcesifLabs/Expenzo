import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class TransactionListSkeleton extends StatelessWidget {
  final int itemCount;

  const TransactionListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ShimmerBox.rectangle(width: 24, height: 24, borderRadius: 4),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShimmerBox.textLine(width: 80, height: 18),
                      const SizedBox(width: 8),
                      ShimmerBox.circle(size: 16),
                    ],
                  ),
                  const SizedBox(height: 6),

                  ShimmerBox.textLine(height: 14),
                  const SizedBox(height: 4),
                  ShimmerBox.textLine(width: 200, height: 12),
                  const SizedBox(height: 6),

                  ShimmerBox.rectangle(width: 60, height: 18, borderRadius: 9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
