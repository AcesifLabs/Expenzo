import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_progress_colors.dart';

void main() {
  for (final (name, palette) in [
    ('light', AppPalette.light),
    ('dark', AppPalette.dark),
  ]) {
    group('budgetProgressColor ($name)', () {
      test('over budget uses the expense color', () {
        expect(budgetProgressColor(palette, 100.1), palette.expense);
        expect(budgetProgressColor(palette, 250), palette.expense);
      });

      test('80% up to exactly 100% warns', () {
        expect(budgetProgressColor(palette, 80), palette.warning);
        expect(budgetProgressColor(palette, 95), palette.warning);
        expect(budgetProgressColor(palette, 100), palette.warning);
      });

      test('below 80% is on track', () {
        expect(budgetProgressColor(palette, 79.9), palette.income);
        expect(budgetProgressColor(palette, 0), palette.income);
      });
    });
  }
}
