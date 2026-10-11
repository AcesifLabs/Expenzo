import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/budget_name.dart';

void main() {
  group('isPlaceholderBudgetName', () {
    for (final name in ['', '   ', AppConstants.defaultBudgetName]) {
      test('is true for "$name"', () {
        expect(isPlaceholderBudgetName(name), isTrue);
      });
    }

    test('is false for a real name', () {
      expect(isPlaceholderBudgetName('Groceries'), isFalse);
    });
  });
}
