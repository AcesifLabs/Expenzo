import 'package:expense_tracker/features/parsing_rules/domain/services/rule_evaluator.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/date_order.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/evaluate_rules_params.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:flutter_test/flutter_test.dart';

final _broadAmountPattern = RegExp(r'\d[\d,]*\.?\d*');

void main() {
  const userBugSms =
      'Your A/C (***6538) has been debited BDT 230.00. '
      'Avl Bal: BDT 1,74,094.39 @ 07:26 PM. For query: 16419';

  group(
    'resolveAmountMatch — 4-candidate SMS (regression for EX-34-35-36)',
    () {
      final allMatches = _broadAmountPattern.allMatches(userBugSms).toList();

      test('broad regex captures all numeric tokens in the SMS '
          '(4 money + 2 time digits)', () {
        expect(allMatches.length, equals(6));
        expect(allMatches.map((m) => m.group(0)).toList(), [
          '6538',
          '230.00',
          '1,74,094.39',
          '07',
          '26',
          '16419',
        ]);
      });

      test(
        'scorer ignores the time digits and picks the real 230.00 amount',
        () {
          final result = RuleEvaluator.resolveAmountMatch(
            allMatches,
            null,
            userBugSms,
          );
          expect(result, isNotNull);
          expect(result!.group(0), equals('230.00'));
        },
      );

      test('respects selectedAmount when the user explicitly pins a value', () {
        final result = RuleEvaluator.resolveAmountMatch(
          allMatches,
          '1,74,094.39',
          userBugSms,
        );
        expect(result, isNotNull);
        expect(result!.group(0), equals('1,74,094.39'));
      });

      test(
        'falls back to scoring when selectedAmount is not found in matches',
        () {
          final result = RuleEvaluator.resolveAmountMatch(
            allMatches,
            '999.99',
            userBugSms,
          );

          expect(result, isNotNull);
          expect(result!.group(0), equals('230.00'));
        },
      );
    },
  );

  group('resolveAmountMatch — edge cases', () {
    test('returns null when there are no matches', () {
      const sms = 'No numbers here at all';
      final result = RuleEvaluator.resolveAmountMatch(
        const <Match>[],
        null,
        sms,
      );
      expect(result, isNull);
    });

    test('returns the only match when there is a single candidate', () {
      const sms = 'You spent 50.00 on coffee';
      final matches = _broadAmountPattern.allMatches(sms).toList();
      final result = RuleEvaluator.resolveAmountMatch(matches, null, sms);
      expect(result, isNotNull);
      expect(result!.group(0), equals('50.00'));
    });

    test('penalizes masked account suffix so 75.50 wins over 1234', () {
      const sms = 'Your card ***1234 was used for 75.50 at the store';
      final matches = _broadAmountPattern.allMatches(sms).toList();
      expect(matches.map((m) => m.group(0)).toList(), ['1234', '75.50']);

      final result = RuleEvaluator.resolveAmountMatch(matches, null, sms);
      expect(result!.group(0), equals('75.50'));
    });

    test('penalizes balance indicator so 230.00 wins over 1,74,094.39', () {
      const sms =
          'You have been debited BDT 230.00. '
          'Avl Bal: BDT 1,74,094.39';
      final matches = _broadAmountPattern.allMatches(sms).toList();

      final result = RuleEvaluator.resolveAmountMatch(matches, null, sms);
      expect(result!.group(0), equals('230.00'));
    });

    test('handles Tk (Bangladesh) currency keyword', () {
      const sms =
          'Payment of Tk 1,000.00 to Green Link is successful. '
          'TrxID DG523GSQX6 at 05/07/2026';
      final matches = _broadAmountPattern.allMatches(sms).toList();

      final result = RuleEvaluator.resolveAmountMatch(matches, null, sms);
      expect(result!.group(0), equals('1,000.00'));
    });

    test('handles lowercase trigger words (case-insensitive scoring)', () {
      const sms =
          'credited inr 1,200.00 to your account. '
          'available balance inr 50,000.00';
      final matches = _broadAmountPattern.allMatches(sms).toList();

      final result = RuleEvaluator.resolveAmountMatch(matches, null, sms);
      expect(result!.group(0), equals('1,200.00'));
    });

    test('on a score tie, the leftmost candidate wins', () {
      const sms = 'Order #1234 and #5678 confirmed';
      final matches = _broadAmountPattern.allMatches(sms).toList();
      expect(matches.map((m) => m.group(0)).toList(), ['1234', '5678']);

      final result = RuleEvaluator.resolveAmountMatch(matches, null, sms);
      expect(result, isNotNull);
      expect(result!.group(0), equals('1234'));
    });
  });

  group('a rule reads dates in its Date Order', () {
    DateTime? dateWith(DateOrder order) => RuleEvaluator.evaluateWithContext(
      ParsingContext(
        rules: [
          ParsingRule(
            id: 'bank',
            name: 'Bank',
            triggerWords: const ['debited'],
            amountPattern: r'BDT ([\d,.]+)',
            datePattern: r'\d{2}/\d{2}/\d{4}',
            sourceType: SourceType.sms,
            isEnabled: true,
            priority: 0,
            dateOrder: order,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ],
        templates: const [],
        sources: const [],
      ),
      const EvaluateRulesParams(
        rawMessage: 'A/C debited BDT 230.00 on 05/10/2026',
        sourceType: AppSourceType.sms,
        sourceId: 'sms-1',
      ),
    )?.date;

    test('day/month by default', () {
      expect(dateWith(DateOrder.dmy), DateTime(2026, 10, 5));
    });

    test('month/day when the rule says so', () {
      expect(dateWith(DateOrder.mdy), DateTime(2026, 5, 10));
    });
  });
}
