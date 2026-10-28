import 'package:expense_tracker/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rounds to 2 decimals', () {
    expect(roundMoney(10.0049), 10.0);
    expect(roundMoney(12.345), 12.35);
    expect(roundMoney(-12.344), -12.34);
  });

  test('1.005 rounds down: it is stored as 1.00499999...', () {
    expect(roundMoney(1.005), 1.0);
  });

  test('negative zero becomes zero', () {
    expect(roundMoney(-0.001).isNegative, isFalse);
  });

  test('1000 random cent amounts sum to within half a cent', () {
    var cents = 0;
    var total = 0.0;
    for (var i = 0; i < 1000; i++) {
      final value = (i * 7919) % 100000;
      cents += value;
      total = roundMoney(total + value / 100);
    }

    expect((total - cents / 100).abs(), lessThan(0.005));
  });
}
