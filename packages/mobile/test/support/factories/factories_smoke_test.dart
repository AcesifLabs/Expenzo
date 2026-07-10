import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart'
    show RecurringFrequency;
import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart'
    show SmsType;

import 'record_factory.dart';
import 'budget_factory.dart';
import 'recurring_factory.dart';
import 'category_factory.dart';
import 'user_settings_factory.dart';
import 'sms_message_factory.dart';
import 'incoming_sms_event_factory.dart';
import 'sync_queue_factory.dart';

void main() {
  group('Factory smoke tests', () {
    test('makeRecord with defaults produces a valid Record', () {
      final r = makeRecord();
      expect(r.id, 'rec-00000001');
      expect(r.amount, 25.50);
      expect(r.recordType, RecordType.expense);
      expect(r.source, ExpenseSource.manual);
      expect(r.date, isNotNull);
      expect(r.createdAt, isNotNull);
      expect(r.updatedAt, isNotNull);
    });

    test('makeRecord with overrides', () {
      final r = makeRecord(
        id: 'custom-id',
        amount: 99.99,
        recordType: RecordType.income,
      );
      expect(r.id, 'custom-id');
      expect(r.amount, 99.99);
      expect(r.recordType, RecordType.income);
      expect(r.description, 'Test expense'); // default preserved
    });

    test('makeBudget with defaults produces a valid Budget', () {
      final b = makeBudget();
      expect(b.id, 'budget-0001');
      expect(b.amount, 500.00);
      expect(b.period, BudgetPeriod.monthly);
      expect(b.isEnabled, true);
      expect(b.rolloverEnabled, false);
    });

    test('makeBudget with overrides', () {
      final b = makeBudget(period: BudgetPeriod.weekly, isEnabled: false);
      expect(b.period, BudgetPeriod.weekly);
      expect(b.isEnabled, false);
    });

    test(
      'makeRecurring with defaults produces a valid RecurringTransaction',
      () {
        final r = makeRecurring();
        expect(r.id, 'recurring-0001');
        expect(r.frequency, RecurringFrequency.monthly);
        expect(r.isActive, true);
        expect(r.autoCreateExpense, true);
        expect(r.endDate, isNull);
        expect(r.dayOfMonth, isNull);
      },
    );

    test('makeCategory with defaults produces a valid Category', () {
      final c = makeCategory();
      expect(c.id, 'cat-0001');
      expect(c.name, 'Food');
      expect(c.type, RecordType.expense);
    });

    test('makeUserSettings with defaults produces valid UserSettings', () {
      final s = makeUserSettings();
      expect(s.id, 1);
      expect(s.currencySymbol, '\$');
      expect(s.notificationsEnabled, true);
      expect(s.theme, 'system');
    });

    test('makeSmsMessage with defaults produces valid SmsMessage', () {
      final m = makeSmsMessage();
      expect(m.id, 'sms-0001');
      expect(m.address, '+1234567890');
      expect(m.type, SmsType.received);
    });

    test(
      'makeIncomingSmsEvent with defaults produces valid IncomingSmsEvent',
      () {
        final e = makeIncomingSmsEvent();
        expect(e.address, '+1234567890');
        expect(e.body, 'Your account was debited \$50.00');
        expect(e.sourceId, isNotEmpty);
      },
    );

    test('makeSyncChange with defaults produces valid map', () {
      final m = makeSyncChange();
      expect(m['table'], 'records');
      expect(m['action'], 'insert');
      expect(m['id'], 'rec-00000001');
      expect(m['data'], isNull);
    });

    test('makeSyncChange with data', () {
      final m = makeSyncChange(table: 'budgets', data: {'amount': 100});
      expect(m['table'], 'budgets');
      expect(m['data'], {'amount': 100});
    });
  });
}
