import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/record.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class RecordDayGroup {
  final DateTime day;
  final List<Record> records;

  const RecordDayGroup(this.day, this.records);
}

List<RecordDayGroup> groupRecordsByDay(List<Record> records) {
  final groups = <RecordDayGroup>[];
  for (final record in records) {
    final day = DateTime(record.date.year, record.date.month, record.date.day);
    if (groups.isNotEmpty && groups.last.day == day) {
      groups.last.records.add(record);
    } else {
      groups.add(RecordDayGroup(day, [record]));
    }
  }

  return groups;
}

String dayHeaderLabel(DateTime day, {DateTime? now}) {
  final current = now ?? clock.now();
  final today = DateTime(current.year, current.month, current.day);

  final difference = DateTime.utc(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime.utc(day.year, day.month, day.day)).inDays;
  final dates = t.common.dates;
  if (difference == 0) return dates.today;
  if (difference == 1) return dates.yesterday;
  final pattern = day.year == today.year ? 'EEE, d MMM' : 'EEE, d MMM y';

  return DateFormat(pattern).format(day);
}
