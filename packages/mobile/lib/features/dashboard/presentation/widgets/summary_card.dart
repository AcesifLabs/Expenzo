import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final double? percentChange;
  final String currencySymbol;
  final bool isLoading;

  static final _currencyFormats = <String, NumberFormat>{};

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.percentChange,
    this.currencySymbol = '৳',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = _currencyFormats.putIfAbsent(
      currencySymbol,
      () => NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2),
    );

    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const SizedBox(
                  height: 32,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                Text(
                  currencyFormat.format(amount),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (percentChange != null && !isLoading) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      percentChange! >= 0
                          ? PiconsRegular.trendUp
                          : PiconsRegular.trendDown,
                      size: 16,
                      color: percentChange! >= 0 ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentChange!.abs().toStringAsFixed(1)}% vs last period',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: percentChange! >= 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
