import 'package:equatable/equatable.dart';

class DateRange extends Equatable {
  final DateRangePreset preset;
  final DateTime? customStart;
  final DateTime? customEnd;

  DateTime get startDate {
    final now = DateTime.now();
    switch (preset) {
      case DateRangePreset.thisMonth:
        return DateTime(now.year, now.month, 1);
      case DateRangePreset.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return lastMonth;
      case DateRangePreset.thisYear:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime get endDate {
    final now = DateTime.now();
    switch (preset) {
      case DateRangePreset.thisMonth:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case DateRangePreset.lastMonth:
        return DateTime(now.year, now.month, 0, 23, 59, 59);
      case DateRangePreset.thisYear:
        return DateTime(now.year, 12, 31, 23, 59, 59);
    }
  }

  DateRange get previousPeriod {
    switch (preset) {
      case DateRangePreset.thisMonth:
        return DateRange.lastMonth();
      case DateRangePreset.lastMonth:
        final now = DateTime.now();
        final prevMonth = DateTime(now.year, now.month - 2, 1);
        return DateRange(
          preset: DateRangePreset.lastMonth,
          customStart: prevMonth,
          customEnd: DateTime(now.year, now.month - 1, 0),
        );
      case DateRangePreset.thisYear:
        return DateRange(
          preset: DateRangePreset.thisYear,
          customStart: DateTime(DateTime.now().year - 1, 1, 1),
          customEnd: DateTime(DateTime.now().year - 1, 12, 31),
        );
    }
  }

  String get label {
    switch (preset) {
      case DateRangePreset.thisMonth:
        return 'This Month';
      case DateRangePreset.lastMonth:
        return 'Last Month';
      case DateRangePreset.thisYear:
        return 'This Year';
    }
  }

  @override
  List<Object?> get props => [preset, customStart, customEnd];

  const DateRange({required this.preset, this.customStart, this.customEnd});

  factory DateRange.thisMonth() =>
      const DateRange(preset: DateRangePreset.thisMonth);

  factory DateRange.lastMonth() =>
      const DateRange(preset: DateRangePreset.lastMonth);

  factory DateRange.thisYear() =>
      const DateRange(preset: DateRangePreset.thisYear);

  DateRange copyWith({
    DateRangePreset? preset,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    return DateRange(
      preset: preset ?? this.preset,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
    );
  }

  bool isInRange(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }
}

enum DateRangePreset { thisMonth, lastMonth, thisYear }
