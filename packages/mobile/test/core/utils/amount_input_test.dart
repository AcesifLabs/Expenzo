import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';

void main() {
  test('reads Latin and Bangla digits with commas', () {
    expect(parseAmountInput('45000'), 45000);
    expect(parseAmountInput('45,000'), 45000);
    expect(parseAmountInput(' 45,000.50 '), 45000.5);
    expect(parseAmountInput('৪৫,০০০.৫০'), 45000.5);
    expect(parseAmountInput('৪৫,০০০'), 45000);
  });

  test('refuses what is not a plain amount', () {
    for (final text in ['', 'abc', '-5', '1.234', '1.2.3']) {
      expect(parseAmountInput(text), isNull, reason: text);
    }
  });

  test('accepts up to the backend maximum', () {
    expect(parseAmountInput('9,999,999,999.99'), 9999999999.99);
    expect(parseAmountInput('10000000000'), isNull);
  });
}
