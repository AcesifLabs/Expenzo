import 'package:equatable/equatable.dart';

/// The date ranges offered on the Export data screen. The range applies to
/// transactions only; budgets and categories are always exported in full.
enum ExportRange { allTime, thisYear, lastSixMonths, lastThreeMonths, custom }

/// The files an export can include, one CSV each.
enum ExportContent { transactions, budgets, categories }

/// What the user asked to export.
class ExportRequest extends Equatable {
  final ExportRange range;

  /// The first and last day of a [ExportRange.custom] range, both included.
  final DateTime? customStart;
  final DateTime? customEnd;

  final Set<ExportContent> contents;

  @override
  List<Object?> get props => [range, customStart, customEnd, contents];

  /// False when nothing is selected, or a custom range is missing a date or
  /// starts after it ends.
  bool get isValid {
    if (contents.isEmpty) return false;
    if (range != ExportRange.custom) return true;
    final start = customStart;
    final end = customEnd;
    if (start == null || end == null) return false;

    return !_day(start).isAfter(_day(end));
  }

  const ExportRequest({
    required this.range,
    this.customStart,
    this.customEnd,
    required this.contents,
  });

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
