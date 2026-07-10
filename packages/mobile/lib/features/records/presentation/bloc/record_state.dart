import 'package:equatable/equatable.dart';
import '../../domain/entities/record.dart';

/// Sentinel value used to distinguish "not provided" from "set to null"
/// in [RecordLoaded.copyWith]. Do not compare to this directly; use
/// [RecordLoaded._isSentinel] instead.
class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

sealed class RecordState extends Equatable {
  @override
  List<Object?> get props => [];

  const RecordState();
}

class RecordInitial extends RecordState {
  const RecordInitial();
}

class RecordLoading extends RecordState {
  const RecordLoading();
}

class RecordLoadingMore extends RecordState {
  final List<Record> currentRecords;
  final int total;

  @override
  List<Object?> get props => [currentRecords, total];

  const RecordLoadingMore({required this.currentRecords, required this.total});
}

class RecordLoaded extends RecordState {
  final List<Record> records;
  final int total;
  final bool hasMore;
  final String searchQuery;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final List<String>? filterCategoryIds;
  final String? filterRecordType;

  List<Record> get filteredRecords {
    if (searchQuery.isEmpty) return records;

    final q = searchQuery.toLowerCase();

    return records
        .where((r) => r.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  List<Object?> get props => [
    records,
    total,
    hasMore,
    searchQuery,
    filterStartDate,
    filterEndDate,
    filterCategoryIds,
    filterRecordType,
  ];

  const RecordLoaded({
    required this.records,
    this.total = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.filterStartDate,
    this.filterEndDate,
    this.filterCategoryIds,
    this.filterRecordType,
  });

  /// Creates a copy with updated fields.
  ///
  /// Nullable filter fields ([filterStartDate], [filterEndDate],
  /// [filterCategoryIds], [filterRecordType]) use a sentinel pattern:
  /// - Omitted or `const _sentinel()` → field is preserved unchanged.
  /// - Explicitly passed `null` → field is cleared to `null`.
  /// - Any other value → field is set to that value.
  RecordLoaded copyWith({
    List<Record>? records,
    int? total,
    bool? hasMore,
    String? searchQuery,
    Object? filterStartDate = _sentinel,
    Object? filterEndDate = _sentinel,
    Object? filterCategoryIds = _sentinel,
    Object? filterRecordType = _sentinel,
  }) {
    return RecordLoaded(
      records: records ?? this.records,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStartDate: filterStartDate == _sentinel
          ? this.filterStartDate
          : filterStartDate as DateTime?,
      filterEndDate: filterEndDate == _sentinel
          ? this.filterEndDate
          : filterEndDate as DateTime?,
      filterCategoryIds: filterCategoryIds == _sentinel
          ? this.filterCategoryIds
          : filterCategoryIds as List<String>?,
      filterRecordType: filterRecordType == _sentinel
          ? this.filterRecordType
          : filterRecordType as String?,
    );
  }
}

class RecordError extends RecordState {
  final String message;

  @override
  List<Object?> get props => [message];

  const RecordError(this.message);
}
