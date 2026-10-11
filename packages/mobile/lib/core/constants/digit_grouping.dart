/// How amounts mark thousands and decimals (Settings > Number format).
///
/// Only these three exist; apostrophe and "no separator" were cut
/// (docs/adr/0011).
enum DigitGrouping {
  comma,
  dot,
  space;

  /// Space grouping uses a no-break space so an amount never wraps.
  String get groupSeparator => switch (this) {
    DigitGrouping.comma => ',',
    DigitGrouping.dot => '.',
    DigitGrouping.space => ' ',
  };

  String get decimalSeparator => switch (this) {
    DigitGrouping.dot => ',',
    DigitGrouping.comma || DigitGrouping.space => '.',
  };

  /// The value stored under [name], or [comma] for a missing or unknown one.
  static DigitGrouping fromName(String? name) {
    for (final grouping in values) {
      if (grouping.name == name) return grouping;
    }

    return comma;
  }
}
