import 'package:equatable/equatable.dart';

/// This week's spending so far against the same span of last week.
class WeeklySummary extends Equatable {
  final double thisWeekTotal;
  final double lastWeekTotal;
  final DateTime weekStart;

  /// Null when nothing was spent last week, so there is nothing to compare.
  double? get changePercent => lastWeekTotal == 0
      ? null
      : (thisWeekTotal - lastWeekTotal) / lastWeekTotal * 100;

  @override
  List<Object?> get props => [thisWeekTotal, lastWeekTotal, weekStart];

  const WeeklySummary({
    required this.thisWeekTotal,
    required this.lastWeekTotal,
    required this.weekStart,
  });
}
