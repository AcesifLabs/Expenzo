import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';

void main() {
  group('DigitGrouping separators', () {
    test('comma groups with a comma and uses a decimal point', () {
      expect(DigitGrouping.comma.groupSeparator, ',');
      expect(DigitGrouping.comma.decimalSeparator, '.');
    });

    test('dot groups with a dot and uses a decimal comma', () {
      expect(DigitGrouping.dot.groupSeparator, '.');
      expect(DigitGrouping.dot.decimalSeparator, ',');
    });

    test('space groups with a no-break space and uses a decimal point', () {
      expect(DigitGrouping.space.groupSeparator, ' ');
      expect(DigitGrouping.space.decimalSeparator, '.');
    });
  });

  group('DigitGrouping.fromName', () {
    test('returns the matching value', () {
      expect(DigitGrouping.fromName('dot'), DigitGrouping.dot);
      expect(DigitGrouping.fromName('space'), DigitGrouping.space);
    });

    test('falls back to comma for an unknown name', () {
      expect(DigitGrouping.fromName('apostrophe'), DigitGrouping.comma);
    });

    test('falls back to comma for null', () {
      expect(DigitGrouping.fromName(null), DigitGrouping.comma);
    });
  });
}
