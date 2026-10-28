import 'package:equatable/equatable.dart';

class WeeklySummary extends Equatable {
  final double thisWeekTotal;
  final double lastWeekTotal;
  final DateTime weekStart;

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
