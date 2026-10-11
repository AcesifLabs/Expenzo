import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';

Color budgetProgressColor(AppPalette palette, double percentage) {
  if (percentage > 100) return palette.expense;
  if (percentage >= 80) return palette.warning;

  return palette.income;
}
