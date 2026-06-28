import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class InsightsSkeleton extends StatelessWidget {
  final int itemCount;

  const InsightsSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(itemCount, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: ShimmerBox.circle(size: 40),
                title: ShimmerBox.textLine(height: 14),
                subtitle: ShimmerBox.textLine(width: 100, height: 12),
                trailing: ShimmerBox.textLine(width: 70, height: 18),
              ),
            );
          }),
        ),
      ),
    );
  }
}
