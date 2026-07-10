import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formats amount with default symbol (৳)', () {
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

    test('formats with custom decimal digits', () {
      final result = CurrencyFormatter.format(1.234, decimalDigits: 3);
      expect(result, contains('1.234'));
    });

    test('formats large amount with thousand separators', () {
      final result = CurrencyFormatter.format(1234567.89);
      expect(result, contains('1,234,567.89'));
    });
  });

  group('CurrencyFormatter.formatSigned', () {
    test('positive amount has + prefix', () {
      final result = CurrencyFormatter.formatSigned(42.50, symbol: '\$');
      expect(result, contains('+'));
      expect(result, contains('42.50'));
      expect(result, contains('\$'));
    });

    test('negative amount has - prefix', () {
      final result = CurrencyFormatter.formatSigned(-42.50, symbol: '\$');
      expect(result, contains('-'));
      expect(result, contains('42.50'));
      expect(result, contains('\$'));
    });

    test('zero is treated as positive', () {
      final result = CurrencyFormatter.formatSigned(0, symbol: '\$');
      expect(result, startsWith('+'));
      expect(result, contains('0.00'));
    });

    test('uses default symbol when none provided', () {
      final result = CurrencyFormatter.formatSigned(10.0);
      expect(result, contains('+'));
      expect(result, contains('৳'));
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

    test('uses default symbol when none provided', () {
      final fmt = CurrencyFormatter.getFormatter();
      final result = fmt.format(100.0);
      expect(result, contains('৳'));
    });
  });
}
