import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/utils/money_format.dart';

void main() {
  test('a symbol with a dot is not altered by dot grouping', () {
    final fmt = MoneyFormat(
      symbol: 'X.',
      decimalDigits: 2,
      grouping: DigitGrouping.dot,
    );

    expect(fmt.format(1234.5), 'X.1.234,50');
    expect(fmt.format(-1234.5), '-X.1.234,50');
  });

  test('a symbol with a comma is not altered by space grouping', () {
    final fmt = MoneyFormat(
      symbol: 'Y,',
      decimalDigits: 2,
      grouping: DigitGrouping.space,
    );

    expect(fmt.format(1234.5), 'Y,1 234.50');
  });

  test('plain has no symbol', () {
    final fmt = MoneyFormat.plain(
      decimalDigits: 0,
      grouping: DigitGrouping.comma,
    );

    expect(fmt.format(123456789), '123,456,789');
  });

  group('the sign follows the rounded number', () {
    final whole = MoneyFormat(
      symbol: '৳',
      decimalDigits: 0,
      grouping: DigitGrouping.comma,
    );

    test('an amount that rounds to zero shows no minus', () {
      expect(whole.format(-0.4), '৳0');
      expect(whole.formatSigned(-0.4), '+৳0');
      expect(whole.formatCompact(-0.4), '৳0');
    });

    test('an amount that rounds away from zero keeps it', () {
      expect(whole.format(-0.6), '-৳1');
      expect(whole.formatSigned(-0.6), '-৳1');
    });
  });

  test('one MoneyFormat formats many amounts', () {
    final fmt = MoneyFormat(
      symbol: '৳',
      decimalDigits: 2,
      grouping: DigitGrouping.dot,
    );

    expect(fmt.format(1234.5), '৳1.234,50');
    expect(fmt.format(99), '৳99,00');
    expect(fmt.formatCompact(1500), '৳1,5K');
  });
}
