import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';

/// Creates a [Record] for tests. All params optional with deterministic defaults.
Record makeRecord({
  String? id,
  double? amount,
  String? description,
  DateTime? date,
  String? categoryId,
  ExpenseSource? source,
  String? sourceId,
  RecordType? recordType,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Record(
    id: id ?? 'rec-00000001',
    amount: amount ?? 25.50,
    description: description ?? 'Test expense',
    date: date ?? DateTime(2024, 6, 15, 10, 30),
    categoryId: categoryId,
    source: source ?? ExpenseSource.manual,
    sourceId: sourceId,
    recordType: recordType ?? RecordType.expense,
    createdAt: createdAt ?? DateTime(2024, 6, 15, 10, 30),
    updatedAt: updatedAt ?? DateTime(2024, 6, 15, 10, 30),
  );
}
