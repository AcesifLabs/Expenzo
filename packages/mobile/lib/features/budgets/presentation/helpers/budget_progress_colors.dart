import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

Color budgetProgressColor(double percentage) {
  if (percentage > 100) return AppColors.expenseDark;
  if (percentage >= 80) return AppColors.warningDark;

  return AppColors.successDark;
}
