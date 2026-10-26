import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../domain/entities/date_amount.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class TrendBarChart extends StatelessWidget {
  final List<DateAmount> data;

  const TrendBarChart({super.key, required this.data});

  List<double> _normalizedBars() {
    if (data.isEmpty) return [];

    final amounts = data.map((item) => item.amount.abs()).toList();
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

  Color _barColor(AppPalette palette, int index, int length, double height) {
    if (height == 1.0) return palette.expense;
    if (index == length - 1) return palette.accent;
    if (height == 0) return palette.textSecondary.withAlpha(0x18);

    return palette.textSecondary.withAlpha(0x30);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bars = _normalizedBars();

    if (bars.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            t.reports.noTrendData,
            style: AppTypography.bodySmall.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < bars.length; i++) ...[
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 24),
                    height: 200 * bars[i] + (bars[i] == 0 ? 2 : 0),
                    decoration: BoxDecoration(
                      color: _barColor(palette, i, bars.length, bars[i]),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusPill),
                      ),
                    ),
                  ),
                ),
              ),
              if (i != bars.length - 1) const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}
