import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_stat_tile.dart';
import '../../domain/entities/spending_insights.dart';

class InsightsCard extends StatelessWidget {
  final SpendingInsights insights;

  const InsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppStatTile(
          icon: PhosphorIcons.trendUp(PhosphorIconsStyle.regular),
          title: 'Highest Spending Day',
          value: insights.highestDayDate != null
              ? DateFormat('dd MMM yyyy').format(insights.highestDayDate!)
              : 'N/A',
          subtitle: '\$${insights.highestDayAmount.toStringAsFixed(2)}',
          color: Colors.orange,
        ),
        AppStatTile(
          icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.regular),
          title: 'Average Daily Spending',
          value: '\$${insights.avgDailySpending.toStringAsFixed(2)}',
          subtitle: 'Per day in selected period',
          color: Colors.blue,
        ),
        AppStatTile(
          icon: PhosphorIcons.invoice(PhosphorIconsStyle.regular),
          title: 'Total Transactions',
          value: insights.totalTransactionCount.toString(),
          subtitle: 'In selected period',
          color: Colors.green,
        ),
        AppStatTile(
          icon: PhosphorIcons.wallet(PhosphorIconsStyle.regular),
          title: 'Total Spent',
          value: '\$${insights.totalSpent.toStringAsFixed(2)}',
          subtitle: 'In selected period',
          color: Colors.purple,
        ),
      ],
    );
  }
}
