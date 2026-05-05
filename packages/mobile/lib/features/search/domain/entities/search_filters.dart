import 'package:equatable/equatable.dart';

class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

class SearchFilters extends Equatable {
  final String? query;
  final int? categoryId;
  final DateRange? dateRange;
  final double? minAmount;
  final double? maxAmount;

  const SearchFilters({
    this.query,
    this.categoryId,
    this.dateRange,
    this.minAmount,
    this.maxAmount,
  });

  SearchFilters copyWith({
    String? query,
    int? categoryId,
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
      query: clearQuery ? null : (query ?? this.query),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }

  bool get isEmpty =>
      query == null &&
      categoryId == null &&
      dateRange == null &&
      minAmount == null &&
      maxAmount == null;

  @override
  List<Object?> get props => [
    query,
    categoryId,
    dateRange,
    minAmount,
    maxAmount,
  ];
}
