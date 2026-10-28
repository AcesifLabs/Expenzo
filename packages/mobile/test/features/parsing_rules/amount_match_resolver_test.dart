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

  group('normalizeResolvedAmount with SMS text around the number', () {
    const cases = {
      'Tk.1,500.00': '1500.00',
      'Rs. 1,74,094.39': '174094.39',
      'BDT 500.': '500',
      'INR250': '250',
      '৳৫০০': '500',
      'Tk ১,২৫০.৫০': '1250.50',
    };
    cases.forEach((input, expected) {
      test('"$input"', () => expect(normalizeResolvedAmount(input), expected));
    });
  });

  group('parseResolvedAmount', () {
    const valid = {
      'Tk.1,500.00': 1500.0,
      '৳৫০০': 500.0,
      '12.345': 12.35,
      '0.01': 0.01,
    };
    valid.forEach((input, expected) {
      test('"$input" is $expected', () {
        expect(parseResolvedAmount(input), expected);
      });
    });

    for (final input in ['0.00', '0', '0.004', '', 'Tk', '1.500.00', 'abc']) {
      test('"$input" is not an amount', () {
        expect(parseResolvedAmount(input), isNull);
      });
    }

    test('anything above the largest amount is rejected', () {
      expect(parseResolvedAmount('99999999999'), isNull);
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

  group('picking the amount among numbers in an SMS', () {
    final anyNumber = RegExp(r'\d[\d,]*\.?\d*');

    String? picked(String sms) => resolveAmountMatch(
      anyNumber.allMatches(sms).toList(),
      null,
      sms,
    )?.group(0);

    const cases = {
      'Card **1234 used for 500': '500',
      'Card XX1234 used for 500': '500',
      'Card xx1234 used for 500': '500',
      'Txn 500 done. Bal 900': '500',
      'Txn 500 done. Balance 900': '500',
      'Txn 500 done. Avl 900': '500',
      'Ref 1234 Tk 500': '500',
      'Ref 1234 Tk: 500': '500',
      'Ref 1234 Rs 500': '500',
      'Ref 1234 BDT 500': '500',
      'Ref 1234 INR 500': '500',
      'Ref 1234 ৳ 500': '500',
      'Ref 1234 debited 500': '500',
      'Ref 1234 spent 500': '500',
      'Ref 1234 paid 500': '500',
      'Ref 1234 now 500.50': '500.50',
    };
    cases.forEach((sms, amount) {
      test('"$sms" -> $amount', () => expect(picked(sms), amount));
    });

    test('a masked number with decimals still loses to a plain one', () {
      expect(picked('Card XX12.50 used 7'), '7');
    });

    test('an amount word after a balance word does not outweigh it', () {
      expect(picked('Order 5 placed. Bal Tk 900'), '5');
    });

    test('a number at the very end of the message is still found', () {
      expect(picked('Ref 1234 Tk 500'), '500');
    });
  });

  group('currency words around the amount', () {
    for (final text in [
      'Tk.1,500.00',
      'Rs.1,500.00',
      'INR 1,500.00',
      'BDT 1,500.00.',
    ]) {
      test('"$text" reads as 1500', () {
        expect(parseResolvedAmount(text), 1500);
      });
    }
  });
}
