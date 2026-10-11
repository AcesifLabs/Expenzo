import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/features/reports/domain/entities/category_amount.dart';
import 'package:expense_tracker/features/reports/presentation/helpers/category_chart_color.dart';

CategoryAmount _item(String? hex) => CategoryAmount(
  categoryId: 'c1',
  categoryName: 'Food',
  emoji: 'forkKnife',
  amount: 100,
  percentage: 50,
  colorHex: hex,
);

void main() {
  test('charts use the category color, not a position in a list', () {
    expect(
      categoryChartColor(_item('#F8BBD0'), AppPalette.light),
      const Color(0xFFF8BBD0),
    );
  });

  test('uncategorized spending uses the neutral tertiary color', () {
    expect(
      categoryChartColor(_item(null), AppPalette.light),
      AppPalette.light.textTertiary,
    );
  });
}
