import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

class SourceBadge extends StatelessWidget {
  final ExpenseSource source;
  final String? categoryName;
  final String? categoryIconName;
  final String? categoryColor;

  const SourceBadge({
    super.key,
    required this.source,
    this.categoryName,
    this.categoryIconName,
    this.categoryColor,
  });

  static Color _sourceColor(ExpenseSource source, AppPalette palette) {
    return switch (source) {
      ExpenseSource.manual => palette.textSecondary,
      ExpenseSource.sms => palette.accent,
      ExpenseSource.email => palette.income,
      ExpenseSource.recurring => palette.warning,
    };
  }

  @override
  Widget build(BuildContext context) {
    final contentColor = Theme.of(context).colorScheme.onSurface;

    final isManualOverride =
        source == ExpenseSource.manual && categoryName != null;

    final label = categoryName ?? source.displayName;
    final iconWidget = isManualOverride
        ? Icon(
            AppIcons.getCategoryIcon(categoryIconName ?? 'package'),
            size: 12,
            color: contentColor,
          )
        : Icon(AppIcons.getSourceIcon(source), size: 12, color: contentColor);

    final catColor = categoryColor;
    Color? hexColor;
    if (isManualOverride && catColor != null) {
      hexColor = ColorUtils.fromHex(catColor);
    }
    final baseColor = hexColor ?? _sourceColor(source, context.palette);

    final bgTint = baseColor.withAlpha(40);
    final borderTint = baseColor.withAlpha(80);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: borderTint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(color: contentColor),
          ),
        ],
      ),
    );
  }
}
