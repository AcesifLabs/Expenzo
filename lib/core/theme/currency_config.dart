class CurrencySymbol {
  final String code;
  final String symbol;

  const CurrencySymbol({required this.code, required this.symbol});
}

class CurrencyConfig {
  static const List<CurrencySymbol> presetSymbols = [
    CurrencySymbol(code: 'BDT', symbol: '৳'),
    CurrencySymbol(code: 'INR', symbol: '₹'),
    CurrencySymbol(code: 'USD', symbol: '\$'),
    CurrencySymbol(code: 'EUR', symbol: '€'),
    CurrencySymbol(code: 'GBP', symbol: '£'),
    CurrencySymbol(code: 'JPY', symbol: '¥'),
    CurrencySymbol(code: 'AUD', symbol: 'A\$'),
    CurrencySymbol(code: 'CAD', symbol: 'C\$'),
    CurrencySymbol(code: 'CHF', symbol: 'CHF'),
  ];

  static const String defaultSymbol = '৳';
  static const String defaultCode = 'BDT';

  String currentSymbol = defaultSymbol;
  String currentCode = defaultCode;

  bool isPreset(String symbol) {
    return presetSymbols.any((cs) => cs.symbol == symbol);
  }

  static bool isValidUnicode(String symbol) {
    if (symbol.isEmpty) return false;
    final codeUnit = symbol.codeUnitAt(0);
    return codeUnit >= 0x20 && codeUnit <= 0x7E;
  }
}
