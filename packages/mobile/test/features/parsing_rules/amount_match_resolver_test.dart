import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/amount_match_resolver.dart';

void main() {
  group('normalizeResolvedAmount', () {
    test('removes non-numeric characters except decimal', () {
      expect(normalizeResolvedAmount('৳1,234.56'), '1234.56');
    });

    test('handles plain number', () {
      expect(normalizeResolvedAmount('100'), '100');
    });

    test('handles empty string', () {
      expect(normalizeResolvedAmount(''), '');
    });

    test('removes currency symbols', () {
      expect(normalizeResolvedAmount('\$50.00'), '50.00');
    });
  });

  group('resolveAmountMatch', () {
    test('returns null for empty matches', () {
      final result = resolveAmountMatch([], null, 'test message');
      expect(result, isNull);
    });

    test('returns first match when no selected amount', () {
      final regex = RegExp(r'(\d+)');
      final matches = regex.allMatches('Amount: 100').toList();

      final result = resolveAmountMatch(matches, null, 'Amount: 100');

      expect(result, isNotNull);
      expect(result!.group(0), '100');
    });

    test('finds exact match when selected amount provided', () {
      final regex = RegExp(r'(\d+)');
      final matches = regex.allMatches('Amount: 100 or 200').toList();

      final result = resolveAmountMatch(matches, '200', 'Amount: 100 or 200');

      expect(result, isNotNull);
      expect(result!.group(0), '200');
    });

    test('falls back to scored match when exact not found', () {
      final regex = RegExp(r'(\d+)');
      final matches = regex.allMatches('Spent: 50 Balance: 1000').toList();

      final result = resolveAmountMatch(
        matches,
        '999',
        'Spent: 50 Balance: 1000',
      );

      expect(result, isNotNull);
    });
  });
}
