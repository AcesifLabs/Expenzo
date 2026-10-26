import 'package:flutter/material.dart';
import 'package:expense_tracker/core/utils/money_format.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

class BalanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final MoneyFormat currencyFmt;

  const BalanceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.currencyFmt,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppSpacing.sm),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: onSurface.withAlpha(140),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  currencyFmt.format(amount),
                  maxLines: 1,
                  style: AppTypography.titleMedium.copyWith(
                    color: onSurface,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
