import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class CategoryBreakdownSkeleton extends StatelessWidget {
  final int rowCount;

  const CategoryBreakdownSkeleton({super.key, this.rowCount = 4});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox.textLine(width: 160, height: 18),
            const SizedBox(height: 16),

            ...List.generate(rowCount, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryRowSkeleton(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ShimmerBox.circle(size: 20),
            const SizedBox(width: 8),

            Expanded(child: ShimmerBox.textLine(height: 14)),
            const SizedBox(width: 8),

            ShimmerBox.textLine(width: 70, height: 14),
          ],
        ),
        const SizedBox(height: 4),

        Row(
          children: [
            Expanded(
              child: ShimmerBox.rectangle(
                width: double.infinity,
                height: 8,
                borderRadius: 4,
              ),
            ),
            const SizedBox(width: 8),
            ShimmerBox.textLine(width: 40, height: 12),
          ],
        ),
      ],
    );
  }
}
