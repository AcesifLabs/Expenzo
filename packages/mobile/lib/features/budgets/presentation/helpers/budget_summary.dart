import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// What a budget card leads with: money left (or how far over) and time left.
class BudgetSummary {
  /// Positive while under the limit, negative when over.
  final double remaining;
  final int daysLeft;

  bool get isOver => remaining < 0;

  String get daysLeftLabel {
    final days = t.budgets.days;

    return switch (daysLeft) {
      0 => days.ended,
      1 => days.lastDay,
      _ => days.left(n: daysLeft),
    };
  }

  const BudgetSummary({required this.remaining, required this.daysLeft});

  factory BudgetSummary.of(BudgetProgress progress, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    // periodRange.end is exclusive (the first moment of the next period).
    final end = _dateOnly(progress.periodRange.end);
    final days = end.difference(today).inDays;

    return BudgetSummary(
      remaining: progress.effectiveAmount - progress.spentAmount,
      daysLeft: days < 0 ? 0 : days,
    );
  }

  /// UTC so a daylight-saving change can't make a day 23 hours long.
  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);
}
