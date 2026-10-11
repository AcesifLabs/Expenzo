import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/features/records/presentation/helpers/record_day_groups.dart';

Record _at(DateTime date) => Record(
  id: date.toIso8601String(),
  amount: -10,
  description: 'Lunch',
  date: date,
  recordType: RecordType.expense,
  createdAt: date,
  updatedAt: date,
);

void main() {
  test('groups consecutive records by calendar day, keeping order', () {
    final groups = groupRecordsByDay([
      _at(DateTime(2026, 10, 11, 20)),
      _at(DateTime(2026, 10, 11, 9)),
      _at(DateTime(2026, 10, 9, 12)),
    ]);

    expect(groups.map((g) => g.day), [
      DateTime(2026, 10, 11),
      DateTime(2026, 10, 9),
    ]);
    expect(groups.first.records, hasLength(2));
  });

  test('labels today, yesterday, this year and older days', () {
    final now = DateTime(2026, 10, 11, 15);

    expect(dayHeaderLabel(DateTime(2026, 10, 11), now: now), 'Today');
    expect(dayHeaderLabel(DateTime(2026, 10, 10), now: now), 'Yesterday');
    expect(dayHeaderLabel(DateTime(2026, 10, 6), now: now), 'Tue, 6 Oct');
    expect(dayHeaderLabel(DateTime(2025, 10, 6), now: now), 'Mon, 6 Oct 2025');
  });
}
