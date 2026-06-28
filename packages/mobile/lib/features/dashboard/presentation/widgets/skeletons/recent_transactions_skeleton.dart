import 'package:flutter/material.dart';
import '../../../../../shared/presentation/widgets/shimmer_box.dart';

class RecentTransactionsSkeleton extends StatelessWidget {
  final int itemCount;

  const RecentTransactionsSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShimmerBox.textLine(width: 180, height: 18),
          ),

          ...List.generate(itemCount, (index) {
            return const _TransactionTileSkeleton();
          }),
        ],
      ),
    );
  }
}

class _TransactionTileSkeleton extends StatelessWidget {
  const _TransactionTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ShimmerBox.circle(size: 40),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox.textLine(height: 14),
          const SizedBox(height: 4),
          ShimmerBox.textLine(width: 80, height: 12),
        ],
      ),
      trailing: ShimmerBox.textLine(width: 60, height: 16),
    );
  }
}
