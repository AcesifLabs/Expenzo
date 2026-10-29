import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

void main() {
  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  final amount = CurrencyFormatter.format(500);
  String body({String? description, double value = 500}) =>
      NotificationService.autoImportedRecordBody(
        amount: value,
        description: description,
        sender: 'bKash',
      );

  test('shows the amount and the description', () {
    expect(body(description: 'Daraz payment'), '$amount · Daraz payment');
  });

  test('falls back to the sender without a description', () {
    expect(body(), '$amount from bKash');
  });

  test('a blank description falls back to the sender', () {
    expect(body(description: '   '), '$amount from bKash');
  });

  test('a negative amount is shown without its sign', () {
    expect(
      body(description: 'Daraz payment', value: -500),
      '$amount · Daraz payment',
    );
  });

  test('reads in Bangla', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    expect(body(), 'bKash থেকে ${CurrencyFormatter.format(500)}');
  });

  group('title', () {
    test('names the record type', () {
      expect(
        NotificationService.autoImportedRecordTitle(RecordType.expense),
        'Expense added',
      );
      expect(
        NotificationService.autoImportedRecordTitle(RecordType.income),
        'Income added',
      );
    });

    test('reads in Bangla', () {
      LocaleSettings.setLocaleSync(AppLocale.bn);

      expect(
        NotificationService.autoImportedRecordTitle(RecordType.expense),
        'খরচ যোগ হয়েছে',
      );
    });
  });

  group('link', () {
    test('carries the SMS source id as a query parameter', () {
      const sourceId = 'VK-BANK|1748253600000|a b&c';
      final uri = Uri.parse(
        NotificationService.autoImportedRecordLink(sourceId),
      );

      expect(uri.scheme, 'expenso');
      expect(uri.host, 'records');
      expect(uri.queryParameters['sourceId'], sourceId);
    });
  });

  group('idFor', () {
    final linkA = NotificationService.autoImportedRecordLink('a');
    final linkB = NotificationService.autoImportedRecordLink('b');

    test('gives each auto-imported record its own id', () {
      final idA = NotificationService.idFor(NotificationType.autoImport, linkA);
      final idB = NotificationService.idFor(NotificationType.autoImport, linkB);

      expect(idA, linkA.hashCode);
      expect(idA, isNot(idB));
    });

    test('keeps the recurring id tied to its link', () {
      expect(
        NotificationService.idFor(NotificationType.recurringDue, linkA),
        linkA.hashCode,
      );
    });

    test('a summary without a link does not reuse a record id', () {
      expect(
        NotificationService.idFor(NotificationType.autoImport, null),
        isNot(linkA.hashCode),
      );
    });
  });
}
