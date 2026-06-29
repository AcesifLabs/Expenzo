// ignore_for_file: cyclomatic-complexity

import 'package:equatable/equatable.dart';
import '../../domain/entities/record.dart';

abstract class RecordState extends Equatable {
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

  RecordLoaded copyWith({
    List<Record>? records,
    int? total,
    bool? hasMore,
    String? searchQuery,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    List<String>? filterCategoryIds,
    String? filterRecordType,
  }) {
    return RecordLoaded(
      records: records ?? this.records,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      filterCategoryIds: filterCategoryIds ?? this.filterCategoryIds,
      filterRecordType: filterRecordType ?? this.filterRecordType,
    );
  }
}

class RecordError extends RecordState {
  final String message;

  @override
  List<Object?> get props => [message];

  const RecordError(this.message);
}
