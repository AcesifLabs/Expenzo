import 'package:flutter_test/flutter_test.dart';
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

      test('returns 0.0 for invalid string', () {
        expect(parseSyncAmount('invalid'), 0.0);
      });

      test('returns 0.0 for null', () {
        expect(parseSyncAmount(null), 0.0);
      });

      test('returns 0.0 for non-numeric type', () {
        expect(parseSyncAmount(true), 0.0);
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

      test('returns now for invalid string', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final result = parseSyncDate('invalid');
        expect(result.isAfter(before), true);
      });

      test('returns now for null', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final result = parseSyncDate(null);
        expect(result.isAfter(before), true);
      });
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
}
