import 'package:flutter/painting.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import '../../domain/entities/category_amount.dart';

Color categoryChartColor(CategoryAmount item, AppPalette palette) {
  final hex = item.colorHex;
  if (hex == null || hex.isEmpty) return palette.textTertiary;

  return ColorUtils.fromHex(hex, fallback: palette.textTertiary);
}
