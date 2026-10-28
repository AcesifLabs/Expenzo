import 'dart:math';

import 'package:equatable/equatable.dart';

class _GoalSentinel {
  const _GoalSentinel();
}

const _sentinel = _GoalSentinel();

class Goal extends Equatable {
  final String? id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? targetDate;
  final double? monthlyContribution;
  final DateTime? createdAt;

  double get remaining => max(0, targetAmount - savedAmount);

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

  int? monthsLeft(DateTime now) {
    final date = targetDate;
    if (date == null) return null;
    var months = (date.year - now.year) * 12 + date.month - now.month;
    if (date.day < now.day) months--;

    return max(0, months);
  }

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
