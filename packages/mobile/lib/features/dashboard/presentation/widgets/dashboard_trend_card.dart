import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/reports/domain/entities/date_amount.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class DashboardTrendCard extends StatelessWidget {
  final String title;
  final double totalSpent;

  final double? percentChange;

  final String previousPeriodLabel;
  final List<DateAmount> trend;

  const DashboardTrendCard({
    super.key,
    required this.title,
    required this.totalSpent,
    required this.percentChange,
    required this.previousPeriodLabel,
    required this.trend,
  });

  Color _changeColor(AppPalette palette) {
    final change = percentChange ?? 0;
    if (change > 0) return palette.expense;
    if (change < 0) return palette.income;

    return palette.textSecondary;
  }

  IconData _trendIcon() {
    final change = percentChange;
    if (change == null || change == 0) return PiconsRegular.minus;
    if (change < 0) return PiconsRegular.trendDown;

    return PiconsRegular.trendUp;
  }

  String _changeText() {
    final change = percentChange;
    if (change == null) {
      return t.dashboard.trend.noPrevious(period: previousPeriodLabel);
    }
    if (change == 0) return t.dashboard.trend.same(period: previousPeriodLabel);
    final percent = change.abs().toStringAsFixed(0);

    return change > 0
        ? t.dashboard.trend.up(percent: percent, period: previousPeriodLabel)
        : t.dashboard.trend.down(percent: percent, period: previousPeriodLabel);
  }

  List<double> _normalizedBars() {
    if (trend.isEmpty) return [];

    final amounts = trend.map((item) => item.amount.abs()).toList();
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    if (maxAmount == 0) {
      return List<double>.filled(amounts.length, 0.2);
    }

    return amounts
        .map(
          (amount) => amount == 0 ? 0.0 : (amount / maxAmount).clamp(0.14, 1.0),
        )
        .toList();
  }

  double _barHeight(double fraction) => fraction == 0 ? 2 : 48 * fraction;

  Color _barColor(ColorScheme colors, int index, int length, double height) {
    if (index == length - 1) return colors.primary;
    if (height == 0) return colors.onSurface.withAlpha(20);

    return colors.onSurface.withAlpha(60);
  }

  Widget _buildHeader(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.bodyMedium.copyWith(color: colors.onSurface),
        ),
        Text(
          t.dashboard.trend.spent(
            amount: CurrencyFormatter.getFormatter(
              decimalDigits: 0,
            ).format(totalSpent),
          ),
          style: AppTypography.labelLarge.copyWith(color: colors.error),
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
                t.dashboard.trend.noData,
                style: AppTypography.bodySmall.copyWith(
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
                        constraints: const BoxConstraints(maxWidth: 16),
                        height: _barHeight(bars[i]),
                        decoration: BoxDecoration(
                          color: _barColor(colors, i, bars.length, bars[i]),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusPill),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i != bars.length - 1)
                    const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
    );
  }

  Widget _buildTrendChange(Color changeColor) {
    return Row(
      children: [
        Icon(_trendIcon(), size: 14, color: changeColor),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            _changeText(),
            style: AppTypography.bodySmall.copyWith(color: changeColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bars = _normalizedBars();
    final changeColor = _changeColor(context.palette);

    return AppCard(
      borderRadius: AppSpacing.radiusControl,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colors),
          const SizedBox(height: AppSpacing.smd),
          _buildBarChart(colors, bars),
          const SizedBox(height: AppSpacing.sm),
          _buildTrendChange(changeColor),
        ],
      ),
    );
  }
}
