import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/reports/domain/entities/date_amount.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';

class DashboardTrendCard extends StatelessWidget {
  final String title;
  final double totalSpent;
  final double percentChange;
  final List<DateAmount> trend;

  const DashboardTrendCard({
    super.key,
    required this.title,
    required this.totalSpent,
    required this.percentChange,
    required this.trend,
  });

  Color _changeColor(ColorScheme colors) {
    if (percentChange > 0) return colors.error;
    if (percentChange < 0) return colors.secondary;

    return colors.onSurface.withAlpha(140);
  }

  IconData _trendIcon() {
    if (percentChange < 0) return PiconsRegular.trendDown;

    return PiconsRegular.trendUp;
  }

  String _changeText() {
    if (percentChange == 0) return 'No change vs last month';

    return '${percentChange >= 0 ? '+' : '-'}${percentChange.abs().toStringAsFixed(0)}% vs last month';
  }

  List<double> _normalizedBars() {
    if (trend.isEmpty) return const [];

    final amounts = trend.map((item) => item.amount.abs()).toList();
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    if (maxAmount == 0) {
      return List<double>.filled(amounts.length, 0.2);
    }

    return amounts
        .map((amount) => (amount / maxAmount).clamp(0.14, 1.0))
        .toList();
  }

  Color _barColor(ColorScheme colors, int index, int length, double height) {
    if (height >= 0.92) return colors.error;
    if (index == length - 1 || index % 5 == 0) return colors.primary;

    return colors.onSurface.withAlpha(40);
  }

  Widget _buildHeader(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        Text(
          '${CurrencyFormatter.getFormatter(decimalDigits: 0).format(totalSpent)} spent',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(ColorScheme colors, List<double> bars) {
    return SizedBox(
      height: 48,
      child: bars.isEmpty
          ? Center(
              child: Text(
                'No trend data yet',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withAlpha(140),
                ),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < bars.length; i++) ...[
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 48 * bars[i],
                        decoration: BoxDecoration(
                          color: _barColor(colors, i, bars.length, bars[i]),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i != bars.length - 1) const SizedBox(width: 3),
                ],
              ],
            ),
    );
  }

  Widget _buildTrendChange(Color changeColor) {
    return Row(
      children: [
        Icon(_trendIcon(), size: 14, color: changeColor),
        const SizedBox(width: 4),
        Text(_changeText(), style: TextStyle(fontSize: 12, color: changeColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bars = _normalizedBars();
    final changeColor = _changeColor(colors);

    return AppCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colors),
          const SizedBox(height: 12),
          _buildBarChart(colors, bars),
          const SizedBox(height: 8),
          _buildTrendChange(changeColor),
        ],
      ),
    );
  }
}
