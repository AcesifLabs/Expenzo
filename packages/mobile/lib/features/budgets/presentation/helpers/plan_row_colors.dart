import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';

/// Colors for Plan Rows in order, shared by the plan chart and the row dots.
/// Callers cycle through them when there are more rows.
List<Color> planRowColors(AppPalette palette) => [
  palette.accent,
  palette.brand,
  palette.info,
  palette.income,
  palette.warning,
  palette.expense,
];
