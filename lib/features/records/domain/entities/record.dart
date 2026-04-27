import 'package:equatable/equatable.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import "package:expense_tracker/core/constants/record_type.dart";

class Record extends Equatable {
  final int? id;
  final double amount;
  final String description;
  final DateTime date;
  final int? categoryId;
  final ExpenseSource source;
  final String? sourceId;
  final RecordType recordType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Record({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    this.categoryId,
    this.source = ExpenseSource.manual,
    this.sourceId,
    required this.recordType,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFromScan => source != ExpenseSource.manual;

  Record copyWith({
    int? id,
    double? amount,
    String? description,
    DateTime? date,
    int? categoryId,
    ExpenseSource? source,
    String? sourceId,
    RecordType? recordType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Record(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      recordType: recordType ?? this.recordType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    date,
    categoryId,
    source,
    sourceId,
    recordType,
    createdAt,
    updatedAt,
  ];
}
