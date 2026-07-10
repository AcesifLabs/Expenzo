import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';

/// Creates a [RecurringTransaction] for tests. All params optional with deterministic defaults.
RecurringTransaction makeRecurring({
  String? id,
  String? description,
  double? amount,
  String? categoryId,
  RecurringFrequency? frequency,
  DateTime? startDate,
  DateTime? endDate,
  DateTime? nextOccurrence,
  bool? isActive,
  bool? autoCreateExpense,
  int? dayOfMonth,
}) {
  return RecurringTransaction(
    id: id ?? 'recurring-0001',
    description: description ?? 'Test recurring expense',
    amount: amount ?? 49.99,
    categoryId: categoryId,
    frequency: frequency ?? RecurringFrequency.monthly,
    startDate: startDate ?? DateTime(2024, 1, 1),
    endDate: endDate,
    nextOccurrence: nextOccurrence ?? DateTime(2024, 2, 1),
    isActive: isActive ?? true,
    autoCreateExpense: autoCreateExpense ?? true,
    dayOfMonth: dayOfMonth,
  );
}
