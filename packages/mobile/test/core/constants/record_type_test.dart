import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

void main() {
  group('RecordType.fromDbValue', () {
    test('returns income for IN', () {
      expect(RecordType.fromDbValue('IN'), RecordType.income);
    });

    test('returns expense for OUT', () {
      expect(RecordType.fromDbValue('OUT'), RecordType.expense);
    });

    test('returns expense for unknown value', () {
      expect(RecordType.fromDbValue('UNKNOWN'), RecordType.expense);
    });
  });

  group('RecordType.displayName', () {
    test('income has correct display name', () {
      expect(RecordType.income.displayName, 'Income');
    });

    test('expense has correct display name', () {
      expect(RecordType.expense.displayName, 'Expense');
    });
  });

  group('RecordType.dbValue', () {
    test('income maps to IN', () {
      expect(RecordType.income.dbValue, 'IN');
    });

    test('expense maps to OUT', () {
      expect(RecordType.expense.dbValue, 'OUT');
    });
  });
}
