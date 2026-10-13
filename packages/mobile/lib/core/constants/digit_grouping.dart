import 'package:expense_tracker/i18n/strings.g.dart';

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
    DigitGrouping.space => '\u00A0',
  };

  String get decimalSeparator => switch (this) {
    DigitGrouping.dot => ',',
    DigitGrouping.comma || DigitGrouping.space => '.',
  };

  String get displayName {
    final labels = t.enums.digitGrouping;

    return switch (this) {
      DigitGrouping.comma => labels.comma,
      DigitGrouping.dot => labels.dot,
      DigitGrouping.space => labels.space,
    };
  }

  /// The value stored under [name], or null for a missing or unknown one.
  static DigitGrouping? fromName(String? name) {
    for (final grouping in values) {
      if (grouping.name == name) return grouping;
    }

    return null;
  }
}
