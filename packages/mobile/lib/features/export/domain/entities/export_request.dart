import 'package:equatable/equatable.dart';

enum ExportRange { allTime, thisYear, lastSixMonths, lastThreeMonths, custom }

enum ExportContent { transactions, budgets, categories }

class ExportRequest extends Equatable {
  final ExportRange range;

  final DateTime? customStart;
  final DateTime? customEnd;

  final Set<ExportContent> contents;

  @override
  List<Object?> get props => [range, customStart, customEnd, contents];

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
