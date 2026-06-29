import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formats amount with default symbol', () {
      final result = CurrencyFormatter.format(1000.5);
      expect(result, contains('1,000.50'));
      expect(result, contains('৳'));
    });

    test('formats amount with custom symbol', () {
      final result = CurrencyFormatter.format(500, symbol: '\$');
      expect(result, contains('500.00'));
      expect(result, contains('\$'));
    });

    test('formats zero correctly', () {
      final result = CurrencyFormatter.format(0);
      expect(result, contains('0.00'));
    });

    test('formats negative amount', () {
      final result = CurrencyFormatter.format(-50.5, symbol: '\$');
      expect(result, contains('50.50'));
    });
  });

  group('CurrencyFormatter.formatCompact', () {
    test('formats large number compactly', () {
      final result = CurrencyFormatter.formatCompact(1500, symbol: '\$');
      expect(result, contains('1.5'));
      expect(result, contains('K'));
    });
  });

  group('CurrencyFormatter.getFormatter', () {
    test('returns NumberFormat with correct decimal digits', () {
      final fmt = CurrencyFormatter.getFormatter(
        symbol: '\$',
        decimalDigits: 3,
      );
      final result = fmt.format(100.0);
      expect(result, contains('100.000'));
    });
  });
}
