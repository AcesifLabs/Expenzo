import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/dashboard_summary.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<CategoryAmount> categories;
  final String currencySymbol;

  // Memoized formatter — created once per currency symbol
  static final _currencyFormats = <String, NumberFormat>{};

  const CategoryBreakdownWidget({
    super.key,
    required this.categories,
    this.currencySymbol = '৳',
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No expenses in this period',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final currencyFormat = _currencyFormats.putIfAbsent(
      '$currencySymbol#0',
      () => NumberFormat.currency(symbol: currencySymbol, decimalDigits: 0),
    );

    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spending by Category',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...categories.map(
                (cat) =>
                    _CategoryRow(category: cat, currencyFormat: currencyFormat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extracted widget that receives a pre-built formatter to avoid
/// repeated NumberFormat allocation per category row.
class _CategoryRow extends StatelessWidget {
  final CategoryAmount category;
  final NumberFormat currencyFormat;

  const _CategoryRow({required this.category, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.categoryName,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                currencyFormat.format(category.amount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: category.percentage / 100,
                    backgroundColor: Colors.grey[200],
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${category.percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
