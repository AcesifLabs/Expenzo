import 'package:equatable/equatable.dart';
import '../../domain/entities/record.dart';

abstract class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecords extends RecordEvent {
  const LoadRecords();
}

class LoadMoreRecords extends RecordEvent {
  const LoadMoreRecords();
}

class AddRecordEvent extends RecordEvent {
  final Record record;

  const AddRecordEvent(this.record);

  @override
  List<Object?> get props => [record];
}

class UpdateRecordEvent extends RecordEvent {
  final Record record;

  const UpdateRecordEvent(this.record);

  @override
  List<Object?> get props => [record];
}

class DeleteRecordEvent extends RecordEvent {
  final String id;

  const DeleteRecordEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RefreshRecords extends RecordEvent {
  const RefreshRecords();
}

class SearchRecords extends RecordEvent {
  final String query;
  const SearchRecords(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyFilters extends RecordEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categoryIds;
  final String? recordType;

  const ApplyFilters({
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.recordType,
  });

  @override
  List<Object?> get props => [startDate, endDate, categoryIds, recordType];
}

class ClearFilters extends RecordEvent {
  const ClearFilters();

  @override
  List<Object?> get props => [];
}
