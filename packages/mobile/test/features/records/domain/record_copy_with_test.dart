import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';

void main() {
  final record = Record(
    id: 'r1',
    amount: -450,
    description: 'DARAZ',
    date: DateTime(2026, 10, 11),
    categoryId: 'cat-1',
    budgetId: 'budget-1',
    source: ExpenseSource.sms,
    sourceId: 'sms-42',
    recordType: RecordType.expense,
    createdAt: DateTime(2026, 10, 11),
    updatedAt: DateTime(2026, 10, 11),
  );

  test('leaving a field out keeps it', () {
    final copy = record.copyWith(description: 'Daraz order');

    expect(copy.description, 'Daraz order');
    expect(copy.categoryId, 'cat-1');
    expect(copy.budgetId, 'budget-1');
    expect(copy.sourceId, 'sms-42');
  });

  test('passing null clears the budget, category and source id', () {
    final copy = record.copyWith(
      budgetId: null,
      categoryId: null,
      sourceId: null,
    );

    expect(copy.budgetId, isNull);
    expect(copy.categoryId, isNull);
    expect(copy.sourceId, isNull);
    expect(copy.id, 'r1');
  });

  test('passing a value replaces it', () {
    expect(record.copyWith(budgetId: 'budget-2').budgetId, 'budget-2');
  });
}
