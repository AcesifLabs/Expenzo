import 'dart:math';

import 'package:equatable/equatable.dart';

/// Distinguishes "not provided" from "set to null" in [Goal.copyWith].
class _GoalSentinel {
  const _GoalSentinel();
}

const _sentinel = _GoalSentinel();

/// A savings target. Progress is [savedAmount], entered by hand; a Goal never
/// reads Records or Budgets (ADR 0009).
class Goal extends Equatable {
  final String? id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;
  final double? monthlyContribution;
  final DateTime? createdAt;

  double get remaining => max(0, targetAmount - savedAmount);

  /// Share of the target saved, 0 to 1.
  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);

  bool get isReached => savedAmount >= targetAmount;

  @override
  List<Object?> get props => [
    id,
    name,
    targetAmount,
    savedAmount,
    targetDate,
    monthlyContribution,
    createdAt,
  ];

  const Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    this.targetDate,
    this.monthlyContribution,
    this.createdAt,
  });

  /// Whole calendar months from [now] to [targetDate], never below 0; null
  /// without a date.
  int? monthsLeft(DateTime now) {
    final date = targetDate;
    if (date == null) return null;
    var months = (date.year - now.year) * 12 + date.month - now.month;
    if (date.day < now.day) months--;

    return max(0, months);
  }

  /// [targetDate] and [monthlyContribution] can be cleared by passing null.
  Goal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    Object? targetDate = _sentinel,
    Object? monthlyContribution = _sentinel,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate == _sentinel
          ? this.targetDate
          : targetDate as DateTime?,
      monthlyContribution: monthlyContribution == _sentinel
          ? this.monthlyContribution
          : (monthlyContribution as num?)?.toDouble(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
