import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';

void main() {
  test('each day maps to its DateTime weekday', () {
    expect(FirstDayOfWeek.sunday.weekday, DateTime.sunday);
    expect(FirstDayOfWeek.monday.weekday, DateTime.monday);
    expect(FirstDayOfWeek.saturday.weekday, DateTime.saturday);
  });

  test('materialIndex counts from Sunday = 0', () {
    expect(FirstDayOfWeek.sunday.materialIndex, 0);
    expect(FirstDayOfWeek.monday.materialIndex, 1);
    expect(FirstDayOfWeek.saturday.materialIndex, 6);
  });

  group('FirstDayOfWeek.fromName', () {
    test('returns the matching value', () {
      expect(FirstDayOfWeek.fromName('saturday'), FirstDayOfWeek.saturday);
    });

    test('returns null for an unknown name or null', () {
      expect(FirstDayOfWeek.fromName('friday'), isNull);
      expect(FirstDayOfWeek.fromName(null), isNull);
    });
  });

  group('FirstDayOfWeek.defaultFor', () {
    test('Bangla starts on Saturday', () {
      expect(FirstDayOfWeek.defaultFor('bn'), FirstDayOfWeek.saturday);
    });

    test('other languages start on Monday', () {
      expect(FirstDayOfWeek.defaultFor('en'), FirstDayOfWeek.monday);
      expect(FirstDayOfWeek.defaultFor('fr'), FirstDayOfWeek.monday);
    });
  });

  test('labels read the translated strings', () {
    expect(FirstDayOfWeek.sunday.displayName, 'Sunday');
    expect(FirstDayOfWeek.saturday.displayName, 'Saturday');
  });
}
