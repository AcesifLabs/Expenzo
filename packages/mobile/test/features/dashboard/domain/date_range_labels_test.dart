import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';

void main() {
  test('labels are sentence case', () {
    expect(
      const DateRange(preset: DateRangePreset.thisMonth).label,
      'This month',
    );
    expect(
      const DateRange(preset: DateRangePreset.lastMonth).label,
      'Last month',
    );
    expect(
      const DateRange(preset: DateRangePreset.thisYear).label,
      'This year',
    );
  });

  test('the previous period reads naturally in a sentence', () {
    expect(
      const DateRange(preset: DateRangePreset.thisMonth).previousPeriodNoun,
      'last month',
    );
    expect(
      const DateRange(preset: DateRangePreset.lastMonth).previousPeriodNoun,
      'the month before',
    );
    expect(
      const DateRange(preset: DateRangePreset.thisYear).previousPeriodNoun,
      'last year',
    );
  });
}
