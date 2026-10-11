import 'package:expense_tracker/i18n/strings.g.dart';

/// A currency the user can pick in Settings. See docs/adr/0002.
class CurrencyInfo {
  /// ISO 4217 code, for example `BDT`.
  final String code;

  /// What is printed before amounts. Letter symbols carry a trailing
  /// no-break space so amounts don't run into them ("CHF 12.00").
  final String symbol;

  /// English name; also what the AI assistant is told.
  final String name;
  final int decimalDigits;

  /// The name in the current app language.
  String get displayName => t.currencies.names[code] ?? name;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    this.decimalDigits = 2,
  });
}

abstract final class CurrencyConfig {
  static const defaultCode = 'BDT';

  static const supported = <CurrencyInfo>[
    CurrencyInfo(code: 'BDT', symbol: '৳', name: 'Bangladeshi taka'),
    CurrencyInfo(code: 'USD', symbol: '\$', name: 'US dollar'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British pound'),
    CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian rupee'),
    CurrencyInfo(code: 'PKR', symbol: 'Rs ', name: 'Pakistani rupee'),
    CurrencyInfo(code: 'NPR', symbol: 'Rs ', name: 'Nepalese rupee'),
    CurrencyInfo(code: 'LKR', symbol: 'Rs ', name: 'Sri Lankan rupee'),
    CurrencyInfo(code: 'AED', symbol: 'AED ', name: 'UAE dirham'),
    CurrencyInfo(code: 'SAR', symbol: 'SAR ', name: 'Saudi riyal'),
    CurrencyInfo(code: 'MYR', symbol: 'RM', name: 'Malaysian ringgit'),
    CurrencyInfo(code: 'SGD', symbol: 'S\$', name: 'Singapore dollar'),
    CurrencyInfo(code: 'THB', symbol: '฿', name: 'Thai baht'),
    CurrencyInfo(code: 'PHP', symbol: '₱', name: 'Philippine peso'),
    CurrencyInfo(
      code: 'IDR',
      symbol: 'Rp ',
      name: 'Indonesian rupiah',
      decimalDigits: 0,
    ),
    CurrencyInfo(
      code: 'VND',
      symbol: '₫',
      name: 'Vietnamese dong',
      decimalDigits: 0,
    ),
    CurrencyInfo(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese yen',
      decimalDigits: 0,
    ),
    CurrencyInfo(
      code: 'KRW',
      symbol: '₩',
      name: 'South Korean won',
      decimalDigits: 0,
    ),
    CurrencyInfo(code: 'CNY', symbol: 'CN¥', name: 'Chinese yuan'),
    CurrencyInfo(code: 'AUD', symbol: 'A\$', name: 'Australian dollar'),
    CurrencyInfo(code: 'CAD', symbol: 'C\$', name: 'Canadian dollar'),
    CurrencyInfo(code: 'CHF', symbol: 'CHF ', name: 'Swiss franc'),
    CurrencyInfo(code: 'SEK', symbol: 'kr ', name: 'Swedish krona'),
    CurrencyInfo(code: 'PLN', symbol: 'zł ', name: 'Polish złoty'),
    CurrencyInfo(code: 'TRY', symbol: '₺', name: 'Turkish lira'),
    CurrencyInfo(code: 'RUB', symbol: '₽', name: 'Russian ruble'),
    CurrencyInfo(code: 'BRL', symbol: 'R\$', name: 'Brazilian real'),
    CurrencyInfo(code: 'ZAR', symbol: 'R ', name: 'South African rand'),
  ];

  static CurrencyInfo byCode(String code) {
    for (final currency in supported) {
      if (currency.code == code) return currency;
    }

    return supported.first;
  }

  /// Maps a symbol saved by older app versions to a currency code.
  static String codeForLegacySymbol(String symbol) {
    return _legacySymbolCodes[symbol.trim()] ?? defaultCode;
  }

  // Symbols the old free-text picker offered, plus the old default.
  static const _legacySymbolCodes = {
    '৳': 'BDT',
    '\$': 'USD',
    '€': 'EUR',
    '£': 'GBP',
    '¥': 'JPY',
    '₹': 'INR',
    '₽': 'RUB',
    '₩': 'KRW',
    'R\$': 'BRL',
    'A\$': 'AUD',
    'C\$': 'CAD',
    'CHF': 'CHF',
    'kr': 'SEK',
    'zł': 'PLN',
    '₺': 'TRY',
    '₫': 'VND',
    'R': 'ZAR',
    'RM': 'MYR',
    '₱': 'PHP',
    '฿': 'THB',
  };
}
