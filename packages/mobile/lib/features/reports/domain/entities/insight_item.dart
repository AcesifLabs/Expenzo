import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show IconData;
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/utils/category_display_name.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

enum InsightTone { warning, positive, info, investment }

enum InsightKind {
  highestSpendingDay,
  topCategory,
  bestSavingsWeek,
  recurringReminder,
  budgetReminder,
}

class InsightItem extends Equatable {
  final IconData icon;
  final InsightTone tone;
  final InsightKind kind;

  final DateTime? day;

  final int? percent;
  final String? categoryId;
  final String? categoryName;

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

  String get title {
    final insights = t.reports.insights;

    return switch (kind) {
      InsightKind.highestSpendingDay => insights.highestDay.title,
      InsightKind.topCategory => insights.topCategory.title,
      InsightKind.bestSavingsWeek => insights.bestWeek.title,
      InsightKind.recurringReminder => insights.recurring.title,
      InsightKind.budgetReminder => insights.budgets.title,
    };
  }

  String get description {
    final insights = t.reports.insights;

    return switch (kind) {
      InsightKind.highestSpendingDay => insights.highestDay.description(
        day: _orEmpty(day, DateFormat.EEEE().format),
        percent: percent ?? 0,
      ),
      InsightKind.topCategory => insights.topCategory.description(
        category: categoryDisplayName(id: categoryId, name: categoryName ?? ''),
        percent: percent ?? 0,
      ),
      InsightKind.bestSavingsWeek => insights.bestWeek.description(
        range: _weekRange(),
      ),
      InsightKind.recurringReminder => insights.recurring.description,
      InsightKind.budgetReminder => insights.budgets.description,
    };
  }

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

  String _weekRange() {
    final start = weekStart;
    final end = weekEnd;
    if (start == null || end == null) return '';

    return '${DateFormat.MMMd().format(start)}–${DateFormat.d().format(end)}';
  }

  static String _orEmpty(DateTime? date, String Function(DateTime) format) =>
      date == null ? '' : format(date);
}
