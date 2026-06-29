import 'package:equatable/equatable.dart';
import '../../domain/entities/record.dart';

abstract class RecordEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const RecordEvent();
}

class LoadRecords extends RecordEvent {
  const LoadRecords();
}

class LoadMoreRecords extends RecordEvent {
  const LoadMoreRecords();
}

class AddRecordEvent extends RecordEvent {
  final Record record;

  @override
  List<Object?> get props => [record];

  const AddRecordEvent(this.record);
}

class UpdateRecordEvent extends RecordEvent {
  final Record record;

  @override
  List<Object?> get props => [record];

  const UpdateRecordEvent(this.record);
}

class DeleteRecordEvent extends RecordEvent {
  final String id;

  @override
  List<Object?> get props => [id];

  const DeleteRecordEvent(this.id);
}

class RefreshRecords extends RecordEvent {
  const RefreshRecords();
}

class SearchRecords extends RecordEvent {
  final String query;

  @override
  List<Object?> get props => [query];

  const SearchRecords(this.query);
}

class ApplyFilters extends RecordEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categoryIds;
  final String? recordType;

  @override
  List<Object?> get props => [startDate, endDate, categoryIds, recordType];

  const ApplyFilters({
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.recordType,
  });
}

class ClearFilters extends RecordEvent {
  @override
  List<Object?> get props => [];

  const ClearFilters();
}
