import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class DateRange extends Equatable {
  final DateRangePreset preset;
  final DateTime? customStart;
  final DateTime? customEnd;

  DateTime get startDate {
    final now = clock.now();
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
    final now = clock.now();
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
        final now = clock.now();
        final prevMonth = DateTime(now.year, now.month - 2, 1);
        return DateRange(
          preset: DateRangePreset.lastMonth,
          customStart: prevMonth,
          customEnd: DateTime(now.year, now.month - 1, 0),
        );
      case DateRangePreset.thisYear:
        return DateRange(
          preset: DateRangePreset.thisYear,
          customStart: DateTime(clock.now().year - 1, 1, 1),
          customEnd: DateTime(clock.now().year - 1, 12, 31),
        );
    }
  }

  String get label => switch (preset) {
    DateRangePreset.thisMonth => t.dashboard.range.thisMonth,
    DateRangePreset.lastMonth => t.dashboard.range.lastMonth,
    DateRangePreset.thisYear => t.dashboard.range.thisYear,
  };

  String get netLabel => switch (preset) {
    DateRangePreset.thisMonth => t.dashboard.range.net.thisMonth,
    DateRangePreset.lastMonth => t.dashboard.range.net.lastMonth,
    DateRangePreset.thisYear => t.dashboard.range.net.thisYear,
  };

  String get previousPeriodNoun => switch (preset) {
    DateRangePreset.thisMonth => t.dashboard.range.previous.thisMonth,
    DateRangePreset.lastMonth => t.dashboard.range.previous.lastMonth,
    DateRangePreset.thisYear => t.dashboard.range.previous.thisYear,
  };

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
