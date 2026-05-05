import 'package:equatable/equatable.dart';
import '../../domain/entities/record.dart';

abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object?> get props => [];
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

  const RecordLoadingMore({required this.currentRecords, required this.total});

  @override
  List<Object?> get props => [currentRecords, total];
}

class RecordLoaded extends RecordState {
  final List<Record> records;
  final int total;
  final bool hasMore;
  final String searchQuery;

  const RecordLoaded({
    required this.records,
    this.total = 0,
    this.hasMore = false,
    this.searchQuery = '',
  });

  List<Record> get filteredRecords {
    if (searchQuery.isEmpty) return records;
    final q = searchQuery.toLowerCase();
    return records.where((r) => r.description.toLowerCase().contains(q)).toList();
  }

  RecordLoaded copyWith({
    List<Record>? records,
    int? total,
    bool? hasMore,
    String? searchQuery,
  }) {
    return RecordLoaded(
      records: records ?? this.records,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [records, total, hasMore, searchQuery];
}

class RecordError extends RecordState {
  final String message;

  const RecordError(this.message);

  @override
  List<Object?> get props => [message];
}
