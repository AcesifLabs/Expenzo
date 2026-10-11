import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show IconData;
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/utils/category_display_name.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Semantic tone of an insight; the UI maps it to a palette color.
enum InsightTone { warning, positive, info, investment }

enum InsightKind {
  highestSpendingDay,
  topCategory,
  bestSavingsWeek,
  recurringReminder,
  budgetReminder,
}

/// One insight on the Reports tab.
///
/// Holds the facts only; [title] and [description] are built in the current
/// app language each time they are read, so a language change needs no
/// reload.
class InsightItem extends Equatable {
  final IconData icon;
  final InsightTone tone;
  final InsightKind kind;

  /// The highest spending day ([InsightKind.highestSpendingDay]).
  final DateTime? day;

  /// Percent above the daily average, or the top category's share.
  final int? percent;
  final String? categoryId;
  final String? categoryName;

  /// The lowest spending week ([InsightKind.bestSavingsWeek]).
  final DateTime? weekStart;
  final DateTime? weekEnd;

  @override
  List<Object?> get props => [
    icon,
    tone,
    kind,
    day,
    percent,
    categoryId,
    categoryName,
    weekStart,
    weekEnd,
  ];

  const InsightItem({
    required this.icon,
    required this.tone,
    required this.kind,
    this.day,
    this.percent,
    this.categoryId,
    this.categoryName,
    this.weekStart,
    this.weekEnd,
  });

  String get title {
    return switch (kind) {
      InsightKind.highestSpendingDay => t.reports.insights.highestDay.title,
      InsightKind.topCategory => t.reports.insights.topCategory.title,
      InsightKind.bestSavingsWeek => t.reports.insights.bestWeek.title,
      InsightKind.recurringReminder => t.reports.insights.recurring.title,
      InsightKind.budgetReminder => t.reports.insights.budgets.title,
    };
  }

  String get description {
    return switch (kind) {
      InsightKind.highestSpendingDay =>
        t.reports.insights.highestDay.description(
          day: _orEmpty(day, DateFormat.EEEE().format),
          percent: percent ?? 0,
        ),
      InsightKind.topCategory => t.reports.insights.topCategory.description(
        category: categoryDisplayName(id: categoryId, name: categoryName ?? ''),
        percent: percent ?? 0,
      ),
      InsightKind.bestSavingsWeek => t.reports.insights.bestWeek.description(
        range: _weekRange(),
      ),
      InsightKind.recurringReminder => t.reports.insights.recurring.description,
      InsightKind.budgetReminder => t.reports.insights.budgets.description,
    };
  }

  String _weekRange() {
    final start = weekStart;
    final end = weekEnd;
    if (start == null || end == null) return '';

    return '${DateFormat.MMMd().format(start)}–${DateFormat.d().format(end)}';
  }

  static String _orEmpty(DateTime? date, String Function(DateTime) format) =>
      date == null ? '' : format(date);
}
