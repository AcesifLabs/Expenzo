import 'package:expense_tracker/i18n/strings.g.dart';

class CurrencyInfo {
  final String code;

  final String symbol;

  final String name;
  final int decimalDigits;

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

  static CurrencyInfo byCode(String code) {
    for (final currency in supported) {
      if (currency.code == code) return currency;
    }

    return supported.first;
  }

  static String codeForLegacySymbol(String symbol) {
    return _legacySymbolCodes[symbol.trim()] ?? defaultCode;
  }
}
