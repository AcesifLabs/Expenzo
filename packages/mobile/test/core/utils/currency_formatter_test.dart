import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:intl/intl.dart';

void main() {
  void useCurrency(String code) {
    CurrencyFormatter.current.value = CurrencyConfig.byCode(code);
  }

  void useFormat({
    int decimalPlaces = 2,
    DigitGrouping grouping = DigitGrouping.comma,
  }) {
    CurrencyFormatter.displayFormat.value = NumberDisplayFormat(
      decimalPlaces: decimalPlaces,
      grouping: grouping,
    );
  }

  setUp(() => useCurrency(CurrencyConfig.defaultCode));
  tearDown(() {
    useCurrency(CurrencyConfig.defaultCode);
    CurrencyFormatter.displayFormat.value = NumberDisplayFormat.standard;
  });

  group('formatIn', () {
    test('uses the given currency, not the current one', () {
      CurrencyFormatter.current.value = CurrencyConfig.byCode('BDT');

      expect(
        CurrencyFormatter.formatIn(1234.5, 'USD'),
        CurrencyFormatter.getFormatterFor('USD').format(1234.5),
      );
      expect(
        CurrencyFormatter.formatIn(1234.5, 'USD'),
        contains(CurrencyConfig.byCode('USD').symbol.trim()),
      );
      expect(
        CurrencyFormatter.formatIn(1234.5, 'USD'),
        isNot(contains(CurrencyConfig.byCode('BDT').symbol.trim())),
      );
    });
  });

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

  group('number format setting', () {
    test('zero decimal places rounds for display', () {
      useFormat(decimalPlaces: 0);
      expect(CurrencyFormatter.format(1234.56), '৳1,235');
      expect(CurrencyFormatter.format(1234.56, decimalDigits: 2), '৳1,235');
    });

    test('dot grouping swaps group and decimal marks', () {
      useFormat(grouping: DigitGrouping.dot);
      expect(CurrencyFormatter.format(1234567.89), '৳1.234.567,89');
      expect(CurrencyFormatter.format(-1234.56), '-৳1.234,56');
    });

    test('space grouping uses a no-break space', () {
      useFormat(grouping: DigitGrouping.space);
      expect(CurrencyFormatter.format(1234567.89), '৳1\u00A0234\u00A0567.89');
    });

    test('formatSigned and formatCompact follow the setting', () {
      useFormat(grouping: DigitGrouping.dot);
      expect(CurrencyFormatter.formatSigned(1234.5), '+৳1.234,50');
      expect(CurrencyFormatter.formatSigned(-1234.5), '-৳1.234,50');

      useCurrency('USD');
      expect(CurrencyFormatter.formatCompact(1500), '\$1,5K');
      expect(CurrencyFormatter.formatCompact(-1500), '-\$1,5K');
    });

    test('formatInput ignores the setting', () {
      for (final grouping in DigitGrouping.values) {
        useFormat(decimalPlaces: 0, grouping: grouping);
        expect(CurrencyFormatter.formatInput(1234.5), '1234.5');
      }
    });

    test('JPY with 2 places still shows none', () {
      useCurrency('JPY');
      useFormat(grouping: DigitGrouping.dot);
      expect(CurrencyFormatter.format(1500.75), '¥1.501');
    });

    test('zero decimal places rounds the screen-reader phrase too', () {
      useFormat(decimalPlaces: 0);
      expect(
        CurrencyFormatter.semanticsLabel(1234.56, isExpense: true),
        'Expense, 1,235 Bangladeshi taka',
      );
    });

    test('an amount that rounds to zero shows no minus', () {
      useFormat(decimalPlaces: 0);
      expect(CurrencyFormatter.format(-0.4), '৳0');
      expect(CurrencyFormatter.formatSigned(-0.3), '+৳0');
    });

    test('the screen-reader phrase keeps English marks', () {
      useFormat(grouping: DigitGrouping.dot);
      expect(
        CurrencyFormatter.semanticsLabel(1234.5, isExpense: true),
        'Expense, 1,234.50 Bangladeshi taka',
      );
    });
  });
}
