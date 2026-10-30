import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

class AutoImportedRecord extends Equatable {
  final String sourceId;
  final double amount;
  final String? description;
  final String sender;
  final RecordType recordType;

  @override
  List<Object?> get props => [
    sourceId,
    amount,
    description,
    sender,
    recordType,
  ];

  const AutoImportedRecord({
    required this.sourceId,
    required this.amount,
    this.description,
    required this.sender,
    required this.recordType,
  });
}
