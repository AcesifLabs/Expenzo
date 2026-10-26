import 'package:equatable/equatable.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import "package:expense_tracker/core/constants/record_type.dart";

class _RecordSentinel {
  const _RecordSentinel();
}

const _sentinel = _RecordSentinel();

class Record extends Equatable {
  final String? id;
  final double amount;
  final String description;
  final DateTime date;
  final String? categoryId;
  final String? budgetId;
  final ExpenseSource source;
  final String? sourceId;
  final RecordType recordType;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isFromScan => source != ExpenseSource.manual;

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    date,
    categoryId,
    budgetId,
    source,
    sourceId,
    recordType,
    createdAt,
    updatedAt,
  ];

  const Record({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    this.categoryId,
    this.budgetId,
    this.source = ExpenseSource.manual,
    this.sourceId,
    required this.recordType,
    required this.createdAt,
    required this.updatedAt,
  });

  Record copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    Object? categoryId = _sentinel,
    Object? budgetId = _sentinel,
    ExpenseSource? source,
    Object? sourceId = _sentinel,
    RecordType? recordType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Record(
      id: _v(id, this.id),
      amount: _v(amount, this.amount),
      description: _v(description, this.description),
      date: _v(date, this.date),
      categoryId: categoryId == _sentinel
          ? this.categoryId
          : categoryId as String?,
      budgetId: budgetId == _sentinel ? this.budgetId : budgetId as String?,
      source: _v(source, this.source),
      sourceId: sourceId == _sentinel ? this.sourceId : sourceId as String?,
      recordType: _v(recordType, this.recordType),
      createdAt: _v(createdAt, this.createdAt),
      updatedAt: _v(updatedAt, this.updatedAt),
    );
  }

  static T _v<T>(T? value, T defaultValue) => value ?? defaultValue;
}
