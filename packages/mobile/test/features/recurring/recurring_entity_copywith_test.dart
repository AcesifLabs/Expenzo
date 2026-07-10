import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';

import '../../support/factories/recurring_factory.dart';

void main() {
  group('RecurringTransaction.copyWith clear semantics', () {
    test('omitting endDate preserves the existing value', () {
      final base = makeRecurring(endDate: DateTime(2025, 12, 31));
      final copy = base.copyWith(description: 'updated');
      expect(copy.endDate, DateTime(2025, 12, 31));
    });

    test('explicitly passing null clears endDate', () {
      final base = makeRecurring(endDate: DateTime(2025, 12, 31));
      final copy = base.copyWith(endDate: null);
      expect(copy.endDate, isNull);
    });

    test('setting endDate works', () {
      final base = makeRecurring();
      final copy = base.copyWith(endDate: DateTime(2026, 6, 15));
      expect(copy.endDate, DateTime(2026, 6, 15));
    });

    test('endDate is null by default and stays null when omitted', () {
      final base = makeRecurring(); // endDate defaults to null
      final copy = base.copyWith(amount: 99.99);
      expect(copy.endDate, isNull);
    });

    test('omitting dayOfMonth preserves the existing value', () {
      final base = makeRecurring(dayOfMonth: 15);
      final copy = base.copyWith(description: 'updated');
      expect(copy.dayOfMonth, 15);
    });

    test('explicitly passing null clears dayOfMonth', () {
      final base = makeRecurring(dayOfMonth: 15);
      final copy = base.copyWith(dayOfMonth: null);
      expect(copy.dayOfMonth, isNull);
    });

    test('setting dayOfMonth works', () {
      final base = makeRecurring();
      final copy = base.copyWith(dayOfMonth: 28);
      expect(copy.dayOfMonth, 28);
    });

    test('dayOfMonth is null by default and stays null when omitted', () {
      final base = makeRecurring(); // dayOfMonth defaults to null
      final copy = base.copyWith(amount: 99.99);
      expect(copy.dayOfMonth, isNull);
    });

    test('non-sentinel fields work with ?? semantics (unchanged behavior)', () {
      final base = makeRecurring(
        endDate: DateTime(2025, 12, 31),
        dayOfMonth: 15,
      );
      final copy = base.copyWith(
        description: 'updated',
        amount: 100.0,
        frequency: RecurringFrequency.weekly,
      );
      expect(copy.description, 'updated');
      expect(copy.amount, 100.0);
      expect(copy.frequency, RecurringFrequency.weekly);
      // sentinel fields unchanged
      expect(copy.endDate, DateTime(2025, 12, 31));
      expect(copy.dayOfMonth, 15);
      // other non-sentinel fields preserved
      expect(copy.id, base.id);
      expect(copy.startDate, base.startDate);
    });
  });
}
