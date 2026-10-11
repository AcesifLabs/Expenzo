import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:intl/intl.dart';

void main() {
  void useCurrency(String code) {
    CurrencyFormatter.current.value = CurrencyConfig.byCode(code);
  }

  setUp(() => useCurrency(CurrencyConfig.defaultCode));
  tearDown(() => useCurrency(CurrencyConfig.defaultCode));

  group('format', () {
    test('defaults to taka with two decimals and grouping', () {
      expect(CurrencyFormatter.format(1234567.89), '৳1,234,567.89');
    });

    test('follows the current currency', () {
      useCurrency('USD');
      expect(CurrencyFormatter.format(500), '\$500.00');
    });

    test('letter symbols are separated from the number', () {
      useCurrency('CHF');
      expect(CurrencyFormatter.format(12), 'CHF 12.00');
    });

    test('zero-decimal currencies never show decimals', () {
      useCurrency('JPY');
      expect(CurrencyFormatter.format(1500.75), '¥1,501');
      expect(CurrencyFormatter.format(1500, decimalDigits: 2), '¥1,500');
    });

    test('decimalDigits can drop decimals for summaries', () {
      expect(CurrencyFormatter.format(122, decimalDigits: 0), '৳122');
    });
  });

  group('formatSigned', () {
    test('prefixes + for income and zero', () {
      expect(CurrencyFormatter.formatSigned(42.5), '+৳42.50');
      expect(CurrencyFormatter.formatSigned(0), '+৳0.00');
    });

    test('prefixes - for expenses', () {
      expect(CurrencyFormatter.formatSigned(-42.5), '-৳42.50');
    });
  });

  test('formatCompact abbreviates large amounts', () {
    useCurrency('USD');
    expect(CurrencyFormatter.formatCompact(1500), '\$1.5K');
  });

  group('formatInput', () {
    test('drops trailing zeros and has no symbol', () {
      expect(CurrencyFormatter.formatInput(122), '122');
      expect(CurrencyFormatter.formatInput(122.5), '122.5');
      expect(CurrencyFormatter.formatInput(122.25), '122.25');
    });

    test(
      'never rounds a stored amount away, even in a no-decimal currency',
      () {
        useCurrency('JPY');
        expect(CurrencyFormatter.formatInput(99.6), '99.6');
        expect(CurrencyFormatter.formatInput(12.5), '12.5');
        expect(CurrencyFormatter.formatInput(100), '100');
      },
    );
  });

  group('CurrencyConfig', () {
    test('unknown codes fall back to the default currency', () {
      expect(CurrencyConfig.byCode('XYZ').code, CurrencyConfig.defaultCode);
    });

    test('legacy symbols map to ISO codes', () {
      expect(CurrencyConfig.codeForLegacySymbol('\$'), 'USD');
      expect(CurrencyConfig.codeForLegacySymbol('৳'), 'BDT');
      expect(CurrencyConfig.codeForLegacySymbol('€'), 'EUR');
      expect(CurrencyConfig.codeForLegacySymbol(' £ '), 'GBP');
      expect(CurrencyConfig.codeForLegacySymbol('??'), 'BDT');
    });

    test('every supported code is unique', () {
      final codes = CurrencyConfig.supported.map((c) => c.code).toList();
      expect(codes.toSet().length, codes.length);
    });
  });

  group('in Bangla', () {
    setUp(() {
      LocaleSettings.setLocaleSync(AppLocale.bn);
      Intl.defaultLocale = 'bn';
    });
    tearDown(() {
      LocaleSettings.setLocaleSync(AppLocale.en);
      Intl.defaultLocale = null;
    });

    test('amounts keep Latin digits', () {
      expect(CurrencyFormatter.format(1234.5), '৳1,234.50');
    });

    test('the screen-reader phrase and currency name are translated', () {
      expect(
        CurrencyFormatter.semanticsLabel(122.5, isExpense: true),
        'খরচ, 122.50 বাংলাদেশি টাকা',
      );
    });
  });

  test('the screen-reader phrase reads naturally in English', () {
    expect(
      CurrencyFormatter.semanticsLabel(122.5, isExpense: true),
      'Expense, 122.50 Bangladeshi taka',
    );
  });
}
