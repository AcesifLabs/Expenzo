import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';

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

  static const _colorMap = {
    ExpenseSource.manual: AppColors.textSecondaryLight,
    ExpenseSource.sms: AppColors.primary,
    ExpenseSource.email: AppColors.secondary,
    ExpenseSource.recurring: AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final contentColor = isLight ? Colors.black : Colors.white;

    final isManualOverride =
        source == ExpenseSource.manual && categoryName != null;

    final Color baseColor;
    if (isManualOverride && categoryColor != null) {
      baseColor = Color(int.parse(categoryColor!.replaceFirst('#', '0xFF')));
    } else {
      baseColor = _colorMap[source] ?? AppColors.textSecondaryLight;
    }

    final Color bgTint = baseColor.withAlpha(40);
    final Color borderTint = baseColor.withAlpha(80);

    final label = isManualOverride ? categoryName! : source.displayName;
    final iconWidget = isManualOverride
        ? Icon(
            AppIcons.getCategoryIcon(categoryIconName ?? 'package'),
            size: 12,
            color: contentColor,
          )
        : Icon(
            AppIcons.getSourceIcon(source),
            size: 12,
            color: contentColor,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderTint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: contentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
