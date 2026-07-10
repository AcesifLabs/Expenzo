import 'package:equatable/equatable.dart';
import 'recurring_frequency.dart';

export 'recurring_frequency.dart';

/// Sentinel value used to distinguish "not provided" from "set to null"
/// in [RecurringTransaction.copyWith]. Do not compare to this directly.
class _RecurringSentinel {
  const _RecurringSentinel();
}

const _sentinel = _RecurringSentinel();

class RecurringTransaction extends Equatable {
  final String? id;
  final String description;
  final double amount;
  final String? categoryId;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextOccurrence;
  final bool isActive;
  final bool autoCreateExpense;
  final int? dayOfMonth;

  @override
  List<Object?> get props => [
    id,
    description,
    amount,
    categoryId,
    frequency,
    startDate,
    endDate,
    nextOccurrence,
    isActive,
    autoCreateExpense,
    dayOfMonth,
  ];

  const RecurringTransaction({
    this.id,
    required this.description,
    required this.amount,
    this.categoryId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextOccurrence,
    this.isActive = true,
    this.autoCreateExpense = true,
    this.dayOfMonth,
  });

  bool isDue() =>
      nextOccurrence.isBefore(DateTime.now()) ||
      nextOccurrence.isAtSameMomentAs(DateTime.now());

  /// Creates a copy with updated fields.
  ///
  /// [endDate] and [dayOfMonth] use a sentinel pattern to distinguish
  /// "not provided" from "set to null" (since both are nullable).
  /// - Omitted or `const _sentinel()` → field is preserved unchanged.
  /// - Explicitly passed `null` → field is cleared to `null`.
  /// - Any other value → field is set to that value.
  RecurringTransaction copyWith({
    String? id,
    String? description,
    double? amount,
    String? categoryId,
    RecurringFrequency? frequency,
    DateTime? startDate,
    Object? endDate = _sentinel,
    DateTime? nextOccurrence,
    bool? isActive,
    bool? autoCreateExpense,
    Object? dayOfMonth = _sentinel,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate == _sentinel ? this.endDate : endDate as DateTime?,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      isActive: isActive ?? this.isActive,
      autoCreateExpense: autoCreateExpense ?? this.autoCreateExpense,
      dayOfMonth: dayOfMonth == _sentinel
          ? this.dayOfMonth
          : dayOfMonth as int?,
    );
  }
}
