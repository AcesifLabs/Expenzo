import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class FontSizePreviewCard extends StatelessWidget {
  final double amount;

  const FontSizePreviewCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final fontSizeT = t.settings.fontSize;

    return Container(
      width: double.infinity,
      color: palette.surface,
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  fontSizeT.sampleTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    CurrencyFormatter.format(amount),
                    style: textTheme.titleLarge?.copyWith(
                      color: palette.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            fontSizeT.sampleBody,
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
