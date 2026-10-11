import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../domain/entities/category_amount.dart';
import '../helpers/category_chart_color.dart';
import 'package:expense_tracker/core/utils/category_display_name.dart';

class CategoryLegend extends StatelessWidget {
  final List<CategoryAmount> data;

  const CategoryLegend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;
    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: data.map((item) {
          final color = categoryChartColor(item, palette);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Text(
                    categoryDisplayName(
                      id: item.categoryId,
                      name: item.categoryName,
                    ),
                    style: AppTypography.bodyMedium.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                Text(
                  fmt.format(item.amount),
                  style: AppTypography.labelLarge.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
