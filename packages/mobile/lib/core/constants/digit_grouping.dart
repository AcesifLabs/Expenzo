import 'package:expense_tracker/i18n/strings.g.dart';

enum DigitGrouping {
  comma,
  dot,
  space;

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

  static DigitGrouping? fromName(String? name) {
    for (final grouping in values) {
      if (grouping.name == name) return grouping;
    }

    return null;
  }
}
