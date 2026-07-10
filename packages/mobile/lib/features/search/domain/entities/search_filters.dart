import 'package:equatable/equatable.dart';

class SearchFilters extends Equatable {
  final String? query;
  final String? categoryId;
  final DateRange? dateRange;
  final double? minAmount;
  final double? maxAmount;

  @override
  List<Object?> get props => [
    query,
    categoryId,
    dateRange,
    minAmount,
    maxAmount,
  ];

  bool get isEmpty =>
      query == null &&
      categoryId == null &&
      dateRange == null &&
      minAmount == null &&
      maxAmount == null;

  const SearchFilters({
    this.query,
    this.categoryId,
    this.dateRange,
    this.minAmount,
    this.maxAmount,
  });

  SearchFilters copyWith({
    String? query,
    String? categoryId,
    DateRange? dateRange,
    double? minAmount,
    double? maxAmount,
    bool clearQuery = false,
    bool clearCategoryId = false,
    bool clearDateRange = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return SearchFilters(
      query: _copyWithField(query, this.query, clearQuery),
      categoryId: _copyWithField(categoryId, this.categoryId, clearCategoryId),
      dateRange: _copyWithField(dateRange, this.dateRange, clearDateRange),
      minAmount: _copyWithField(minAmount, this.minAmount, clearMinAmount),
      maxAmount: _copyWithField(maxAmount, this.maxAmount, clearMaxAmount),
    );
  }

  static T? _copyWithField<T>(T? value, T? current, bool clear) =>
      clear ? null : (value ?? current);
}

class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];

  const DateRange({required this.start, required this.end});

  DateRange copyWith({DateTime? start, DateTime? end}) {
    return DateRange(start: start ?? this.start, end: end ?? this.end);
  }
}
