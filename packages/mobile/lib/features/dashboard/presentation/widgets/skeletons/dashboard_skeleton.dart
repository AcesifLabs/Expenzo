import 'package:flutter/material.dart';
import 'summary_card_skeleton.dart';
import 'category_breakdown_skeleton.dart';
import 'recent_transactions_skeleton.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SummaryCardSkeleton(),
          SizedBox(height: 16),
          CategoryBreakdownSkeleton(),
          SizedBox(height: 16),
          RecentTransactionsSkeleton(),
        ],
      ),
    );
  }
}
