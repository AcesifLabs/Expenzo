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
    for (final text in ['', '.', 'abc', '-5', '1.234', '1.2.3']) {
      expect(parseAmountInput(text), isNull, reason: text);
    }
  });

  test('accepts up to the backend maximum', () {
    expect(parseAmountInput('9,999,999,999.99'), 9999999999.99);
    expect(parseAmountInput('10000000000'), isNull);
  });

  test('half-typed amounts still read as numbers', () {
    expect(parseAmountInput('12.'), 12);
    expect(parseAmountInput('.5'), 0.5);
  });

  test('the formatter stops at the largest amount and two decimals', () {
    TextEditingValue typed(String text) => amountInputFormatter
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

    expect(typed('9999999999.99').text, '9999999999.99');
    expect(typed('99999999999').text, '9999999999');
    expect(typed('1.234').text, '1.23');
  });
}
