import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_stat_tile.dart';
import '../../domain/entities/spending_insights.dart';

class InsightsCard extends StatelessWidget {
  final SpendingInsights insights;

  const InsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final highestDayDate = insights.highestDayDate;
    final highestDay = highestDayDate != null
        ? DateFormat('dd MMM yyyy').format(highestDayDate)
        : 'N/A';

    return ListView(
      children: [
        AppStatTile(
          icon: PiconsRegular.trendUp,
          title: 'Highest Spending Day',
          value: highestDay,
          subtitle: '\$${insights.highestDayAmount.toStringAsFixed(2)}',
          color: Colors.orange,
        ),
        AppStatTile(
          icon: PiconsRegular.chartLineUp,
          title: 'Average Daily Spending',
          value: '\$${insights.avgDailySpending.toStringAsFixed(2)}',
          subtitle: 'Per day in selected period',
          color: Colors.blue,
        ),
        AppStatTile(
          icon: PiconsRegular.invoice,
          title: 'Total Transactions',
          value: insights.totalTransactionCount.toString(),
          subtitle: 'In selected period',
          color: Colors.green,
        ),
        AppStatTile(
          icon: PiconsRegular.wallet,
          title: 'Total Spent',
          value: '\$${insights.totalSpent.toStringAsFixed(2)}',
          subtitle: 'In selected period',
          color: Colors.purple,
        ),
      ],
    );
  }
}
