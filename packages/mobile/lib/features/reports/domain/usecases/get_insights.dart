import 'package:dartz/dartz.dart';
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
        final aboveAvg = insights.avgDailySpending > 0
            ? ((insights.highestDayAmount / insights.avgDailySpending - 1) *
                      100)
                  .round()
            : 0;

        items.add(
          InsightItem(
            icon: PiconsRegular.trendUp,
            tone: InsightTone.warning,
            kind: InsightKind.highestSpendingDay,
            day: highestDayDate,
            percent: aboveAvg,
          ),
        );
      }

      if (categoryBreakdown.isNotEmpty) {
        final top = categoryBreakdown.first;

        items.add(
          InsightItem(
            icon: PiconsRegular.shoppingCart,
            tone: InsightTone.info,
            kind: InsightKind.topCategory,
            categoryId: top.categoryId,
            categoryName: top.categoryName,
            percent: top.percentage.round(),
          ),
        );
      }

      if (spendingTrend.length >= 7) {
        final lowestWeek = _findLowestWeek(spendingTrend);
        if (lowestWeek != null) {
          items.add(
            InsightItem(
              icon: PiconsRegular.arrowDown,
              tone: InsightTone.positive,
              kind: InsightKind.bestSavingsWeek,
              weekStart: lowestWeek.start,
              weekEnd: lowestWeek.end,
            ),
          );
        }
      }

      items.add(
        const InsightItem(
          icon: PiconsRegular.coffee,
          tone: InsightTone.investment,
          kind: InsightKind.recurringReminder,
        ),
      );

      items.add(
        const InsightItem(
          icon: PiconsRegular.bell,
          tone: InsightTone.info,
          kind: InsightKind.budgetReminder,
        ),
      );

      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to compute insights: $e'));
    }
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
}

class _WeekRange {
  final DateTime start;
  final DateTime end;
  final double total;

  const _WeekRange(this.start, this.end, this.total);
}
