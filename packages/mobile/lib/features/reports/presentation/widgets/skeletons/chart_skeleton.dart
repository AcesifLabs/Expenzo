import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox.rectangle(width: 80, height: 32, borderRadius: 16),
                const SizedBox(width: 8),
                ShimmerBox.rectangle(width: 80, height: 32, borderRadius: 16),
                const SizedBox(width: 8),
                ShimmerBox.rectangle(width: 80, height: 32, borderRadius: 16),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      5,
                      (_) => ShimmerBox.textLine(width: 40, height: 10),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: ShimmerBox.rectangle(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (_) => ShimmerBox.textLine(width: 30, height: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
