import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/sync/handlers/records_sync_handler.dart';
import 'package:expense_tracker/core/sync/handlers/sync_parse_helpers.dart';

void main() {
  group('Sync parse helpers', () {
    group('parseSyncAmount', () {
      test('parses double value', () {
        expect(parseSyncAmount(50.5), 50.5);
      });

      test('parses int value', () {
        expect(parseSyncAmount(100), 100.0);
      });

      test('parses string value', () {
        expect(parseSyncAmount('75.25'), 75.25);
      });

      // A made-up 0.0 would be saved for good; a throw skips the row so
      // the next pull can try again.
      for (final value in <Object?>['invalid', null, true, 'NaN']) {
        test('throws for $value', () {
          expect(() => parseSyncAmount(value), throwsFormatException);
        });
      }

      test('rounds to 2 decimals', () {
        expect(parseSyncAmount('12.345'), 12.35);
      });
    });

    group('parseSyncDate', () {
      test('parses valid date string', () {
        final result = parseSyncDate('2024-06-15T10:30:00.000Z');
        expect(result.year, 2024);
        expect(result.month, 6);
        expect(result.day, 15);
      });

      test('returns DateTime for DateTime input', () {
        final date = DateTime(2024, 6, 15);
        expect(parseSyncDate(date), date);
      });

      for (final value in <Object?>['invalid', null, 42]) {
        test('throws for $value', () {
          expect(() => parseSyncDate(value), throwsFormatException);
        });
      }
    });

    group('parseSyncString', () {
      test('returns string value', () {
        expect(parseSyncString('hello'), 'hello');
      });

      test('returns fallback for null', () {
        expect(parseSyncString(null), '');
      });

      test('returns custom fallback for null', () {
        expect(parseSyncString(null, 'default'), 'default');
      });

      test('converts non-string to string', () {
        expect(parseSyncString(123), '123');
      });
    });
  });

  group('RecordsSyncHandler budget links', () {
    final base = {
      'amount': 10,
      'description': 'Lunch',
      'date': '2026-10-01T00:00:00.000Z',
      'recordType': 'OUT',
    };

    Value<String?> pulledBudgetId(
      Map<String, dynamic> data, {
      bool Function()? keepLocal,
    }) =>
        (RecordsSyncHandler(
                  keepLocalBudgetLinks: keepLocal,
                ).fromSyncPayload('r1', data)
                as RecordsCompanion)
            .budgetId;

    test('a pulled null keeps the local link while the repair is pending', () {
      expect(
        pulledBudgetId({...base, 'budgetId': null}, keepLocal: () => true),
        const Value<String?>.absent(),
      );
    });

    test('a pulled null clears the local link once the repair is done', () {
      expect(
        pulledBudgetId({...base, 'budgetId': null}, keepLocal: () => false),
        const Value<String?>(null),
      );
    });

    test('a pulled link replaces the local one either way', () {
      for (final keep in [true, false]) {
        expect(
          pulledBudgetId({...base, 'budgetId': 'bud-1'}, keepLocal: () => keep),
          const Value<String?>('bud-1'),
        );
      }
    });

    test('a payload without budgetId never changes the local link', () {
      expect(
        pulledBudgetId(base, keepLocal: () => false),
        const Value<String?>.absent(),
      );
    });

    test('the default handler keeps local links', () {
      expect(
        pulledBudgetId({...base, 'budgetId': null}),
        const Value<String?>.absent(),
      );
    });
  });
}
