import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/entities/spending_insights.dart';

class InsightsCard extends StatelessWidget {
  final SpendingInsights insights;

  const InsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildInsightTile(
          icon: PhosphorIcons.regular.trendUp,
          title: 'Highest Spending Day',
          value: insights.highestDayDate != null
              ? DateFormat('dd MMM yyyy').format(insights.highestDayDate!)
              : 'N/A',
          subtitle: '৳${insights.highestDayAmount.toStringAsFixed(2)}',
          color: Colors.orange,
        ),
        _buildInsightTile(
          icon: PhosphorIcons.regular.activity,
          title: 'Average Daily Spending',
          value: '৳${insights.avgDailySpending.toStringAsFixed(2)}',
          subtitle: 'Per day in selected period',
          color: Colors.blue,
        ),
        _buildInsightTile(
          icon: PhosphorIcons.invoice(PhosphorIconsStyle.regular),
          title: 'Total Transactions',
          value: insights.totalTransactionCount.toString(),
          subtitle: 'In selected period',
          color: Colors.green,
        ),
        _buildInsightTile(
          icon: PhosphorIcons.wallet(PhosphorIconsStyle.regular),
          title: 'Total Spent',
          value: '৳${insights.totalSpent.toStringAsFixed(2)}',
          subtitle: 'In selected period',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildInsightTile({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
