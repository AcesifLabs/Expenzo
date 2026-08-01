import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/receipt_scan/data/receipt_extraction_parser.dart';

void main() {
  const parser = ReceiptExtractionParser();

  group('ReceiptExtractionParser', () {
    test('parses amount, description, date, and category', () {
      final result = parser.parse(
        '{"amount": 42.5, "description": "Coffee run", '
        '"date": "2026-07-15", "category": "Food & Dining"}',
      );

      expect(result.amount, 42.5);
      expect(result.description, 'Coffee run');
      expect(result.date, DateTime(2026, 7, 15));
      expect(result.categoryName, 'Food & Dining');
    });

    test('strips currency symbols from amount strings', () {
      final result = parser.parse(
        '{"amount": "\$12.99", "description": "Lunch"}',
      );

      expect(result.amount, 12.99);
      expect(result.description, 'Lunch');
      expect(result.date, isNull);
      expect(result.categoryName, isNull);
    });

    test('treats null date and category as absent', () {
      final result = parser.parse(
        '{"amount": 10, "description": "Taxi", "date": null, "category": null}',
      );

      expect(result.date, isNull);
      expect(result.categoryName, isNull);
    });

    test('extracts JSON from surrounding markdown', () {
      final result = parser.parse(
        'Here you go:\n```json\n{"amount": 10, "description": "Taxi"}\n```',
      );

      expect(result.amount, 10);
      expect(result.description, 'Taxi');
    });

    test('ignores think blocks and uses the final JSON object', () {
      final result = parser.parse('''
<think>
Construct JSON: `{"amount": 1, "description": "Wrong"}`.
</think>

{"amount":1656.0,"description":"Dim Sum Town meal","date":"2026-07-28","category":"Food & Dining"}
''');

      expect(result.amount, 1656.0);
      expect(result.description, 'Dim Sum Town meal');
      expect(result.date, DateTime(2026, 7, 28));
      expect(result.categoryName, 'Food & Dining');
    });

    test('rejects non-positive amount', () {
      expect(
        () => parser.parse('{"amount": 0, "description": "Shop"}'),
        throwsFormatException,
      );
    });

    test('rejects empty description', () {
      expect(
        () => parser.parse('{"amount": 5, "description": "  "}'),
        throwsFormatException,
      );
    });
  });
}
