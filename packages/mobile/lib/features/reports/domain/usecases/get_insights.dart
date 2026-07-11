import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/insight_item.dart';
import '../entities/date_amount.dart';
import '../entities/spending_insights.dart';
import '../entities/category_amount.dart';

class GetInsights {
  const GetInsights();

  Either<Failure, List<InsightItem>> call({
    required SpendingInsights insights,
    required List<DateAmount> spendingTrend,
    required List<CategoryAmount> categoryBreakdown,
  }) {
    try {
      final items = <InsightItem>[];

      final highestDayDate = insights.highestDayDate;
      if (highestDayDate != null) {
        final dayName = _weekdayName(highestDayDate);
        final aboveAvg = insights.avgDailySpending > 0
            ? ((insights.highestDayAmount / insights.avgDailySpending - 1) *
                      100)
                  .round()
            : 0;

        items.add(
          InsightItem(
            icon: PiconsRegular.trendUp,
            iconColor: const Color(0xFFF48FB1),
            title: 'Highest Spending Day',
            description:
                '$dayName is your biggest spending day — $aboveAvg% above daily average.',
          ),
        );
      }

      if (categoryBreakdown.isNotEmpty) {
        final top = categoryBreakdown.first;

        items.add(
          InsightItem(
            icon: PiconsRegular.shoppingCart,
            iconColor: const Color(0xFFD1C4E9),
            title: 'Most Frequent Category',
            description:
                '${top.categoryName} accounts for ${top.percentage.toStringAsFixed(0)}% of your spending.',
          ),
        );
      }

      if (spendingTrend.length >= 7) {
        final lowestWeek = _findLowestWeek(spendingTrend);
        if (lowestWeek != null) {
          items.add(
            InsightItem(
              icon: PiconsRegular.arrowDown,
              iconColor: const Color(0xFFA2D3A4),
              title: 'Best Savings Week',
              description:
                  '${_formatDateRange(lowestWeek.start, lowestWeek.end)} was your lowest spending week.',
            ),
          );
        }
      }

      items.add(
        const InsightItem(
          icon: PiconsRegular.coffee,
          iconColor: Color(0xFF90CAF9),
          title: 'Recurring Expenses',
          description:
              'Check your recurring transactions for upcoming charges.',
        ),
      );

      items.add(
        const InsightItem(
          icon: PiconsRegular.bell,
          iconColor: Color(0xFFD1C4E9),
          title: 'Budget Status',
          description: 'Review your budgets to stay on track this month.',
        ),
      );

      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to compute insights: $e'));
    }
  }

  String _weekdayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  _WeekRange? _findLowestWeek(List<DateAmount> trend) {
    if (trend.length < 7) return null;

    double minSum = double.infinity;
    _WeekRange? best;

    for (var i = 0; i <= trend.length - 7; i++) {
      final week = trend.sublist(i, i + 7);
      final sum = week.fold<double>(0, (s, d) => s + d.amount);

      if (sum < minSum) {
        minSum = sum;
        best = _WeekRange(week.first.date, week.last.date, sum);
      }
    }

    return best;
  }

  String _formatDateRange(DateTime start, DateTime end) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[start.month - 1]} ${start.day}–${end.day}';
  }
}

class _WeekRange {
  final DateTime start;
  final DateTime end;
  final double total;

  const _WeekRange(this.start, this.end, this.total);
}
