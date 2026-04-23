import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/expense_source.dart';

class SourceBadge extends StatelessWidget {
  final ExpenseSource source;

  const SourceBadge({super.key, required this.source});

  static const _colorMap = {
    ExpenseSource.manual: AppColors.textSecondaryLight,
    ExpenseSource.sms: AppColors.primary,
    ExpenseSource.email: AppColors.secondary,
    ExpenseSource.recurring: AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final bgColor = _colorMap[source] ?? AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: bgColor.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(source.icon, style: TextStyle(fontSize: 10, color: bgColor)),
          const SizedBox(width: 2),
          Text(
            source.displayName,
            style: TextStyle(
              fontSize: 10,
              color: bgColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
