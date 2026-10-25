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

  group('amount edge cases', () {
    const valid = {
      '"12.345"': 12.35,
      '12.345': 12.35,
      '"1.234,50"': 1234.5,
      '"1,234.50"': 1234.5,
      '"1,234"': 1234.0,
      '"45,90"': 45.9,
      '"Tk 1,500"': 1500.0,
    };
    valid.forEach((json, expected) {
      test('$json reads as $expected', () {
        final result = parser.parse('{"amount": $json, "description": "X"}');

        expect(result.amount, expected);
      });
    });

    for (final json in [
      '1e309',
      '-5',
      '0',
      '0.004',
      '1e-308',
      '99999999999',
      '"abc"',
    ]) {
      test('$json is rejected', () {
        expect(
          () => parser.parse('{"amount": $json, "description": "X"}'),
          throwsFormatException,
        );
      });
    }
  });

  group('date edge cases', () {
    test('an impossible date is dropped, not rolled into the next month', () {
      final result = parser.parse(
        '{"amount": 5, "description": "X", "date": "2026-02-31"}',
      );

      expect(result.date, isNull);
    });

    test('Feb 29 is kept in a leap year and dropped otherwise', () {
      DateTime? dateOf(String date) => parser
          .parse('{"amount": 5, "description": "X", "date": "$date"}')
          .date;

      expect(dateOf('2028-02-29'), DateTime(2028, 2, 29));
      expect(dateOf('2027-02-29'), isNull);
    });

    test('a date with a time keeps only the day', () {
      final result = parser.parse(
        '{"amount": 5, "description": "X", "date": "2026-07-15T18:30:00"}',
      );

      expect(result.date, DateTime(2026, 7, 15));
    });
  });

  group('hostile replies', () {
    test('an object nested in the answer does not replace it', () {
      final result = parser.parse(
        '{"amount": 120, "description": "Lunch", "date": null, '
        '"category": null, "meta": {"amount": 5, "description": "Tip"}}',
      );

      expect(result.amount, 120);
      expect(result.description, 'Lunch');
    });

    test('thousands of nested braces fail fast', () {
      final watch = Stopwatch()..start();

      expect(
        () => parser.parse('${'{' * 20000}${'}' * 20000}'),
        throwsFormatException,
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
    });

    test('thousands of unclosed braces fail fast', () {
      final watch = Stopwatch()..start();

      expect(() => parser.parse('{' * 20000), throwsFormatException);
      expect(watch.elapsedMilliseconds, lessThan(500));
    });

    test('an unclosed think block still finds the JSON after it', () {
      final result = parser.parse(
        '<think>the total looks like 12\n{"amount": 7, "description": "Tea"}',
      );

      expect(result.amount, 7);
    });

    test('the error never carries the reply text', () {
      expect(
        () => parser.parse('Total Tk 900 at SHOP X, no JSON here'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            isNot(contains('SHOP')),
          ),
        ),
      );
    });
  });
}
