import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/money_format.dart';

/// [amount] as amounts look now, with and without the currency symbol.
///
/// Reads [CurrencyFormatter], which `CurrencyScope` rebuilds on every
/// change, so a new setting shows here at once.
class NumberFormatPreviewCard extends StatelessWidget {
  final double amount;

  const NumberFormatPreviewCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final formatter = CurrencyFormatter.getFormatter();
    final plain = MoneyFormat.plain(
      decimalDigits: formatter.decimalDigits,
      grouping: formatter.grouping,
    );

    return Container(
      width: double.infinity,
      color: palette.surface,
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatter.format(amount),
            style: textTheme.headlineMedium?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            plain.format(amount),
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
