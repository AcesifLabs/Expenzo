import 'package:expense_tracker/features/parsing_rules/domain/services/rule_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the broad regex a user would configure for a "BDT" amount
/// template: matches any number (with optional commas and decimals).
final _broadAmountPattern = RegExp(r'\d[\d,]*\.?\d*');

void main() {
  // The exact SMS from the user's bug report.
  const userBugSms =
      'Your A/C (***6538) has been debited BDT 230.00. '
      'Avl Bal: BDT 1,74,094.39 @ 07:26 PM. For query: 16419';

  group('resolveAmountMatch — 4-candidate SMS (regression for EX-34-35-36)', () {
    final allMatches = _broadAmountPattern.allMatches(userBugSms).toList();

    test('broad regex captures all numeric tokens in the SMS '
        '(4 money + 2 time digits)', () {
      // BRITTLE ASSERTION — documents what the user-configured broad
      // amount pattern currently captures. If the regex is ever
      // tightened (e.g. to skip time digits or require decimal points),
      // this test will fail for the wrong reason. The real regression
      // for the scorer is in the next test: "scorer ignores the time
      // digits and picks 230.00".
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

    test('scorer ignores the time digits and picks the real 230.00 amount', () {
      // Regression for EX-34-35-36: this test focuses only on the
      // scorer's behavior. It fails for the RIGHT reason if the
      // scoring or tie-break logic regresses, regardless of how many
      // candidates the broad regex captures. The brittle assertion
      // about the regex's 6-candidate output is in the test above.
      final result = RuleEvaluator.resolveAmountMatch(
        allMatches,
        null,
        userBugSms,
      );
      expect(result, isNotNull);
      expect(result!.group(0), equals('230.00'));
    });

    test('respects selectedAmount when the user explicitly pins a value', () {
      // The user re-created the template against the 15.00 message; that
      // selectedAmount should still resolve correctly to its match in any SMS.
      final result = RuleEvaluator.resolveAmountMatch(
        allMatches,
        '1,74,094.39', // pretend user pinned the balance (worst case)
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
          '999.99', // not present in the SMS
          userBugSms,
        );
        // Scorer still runs and picks 230.00 (highest score)
        expect(result, isNotNull);
        expect(result!.group(0), equals('230.00'));
      },
    );
  });

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
      // Same SMS, but the masked account is removed — focus on balance vs
      // real amount.
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
      // Both candidates have no scoring context: no decimal, no
      // currency/action keyword, no balance word, no masked account
      // suffix before them. Both score 0; the documented tie-break
      // is "leftmost wins" so a future refactor cannot silently flip it.
      // Catches a `>=` regression in the loop, which would favor the
      // rightmost candidate.
      const sms = 'Order #1234 and #5678 confirmed';
      final matches = _broadAmountPattern.allMatches(sms).toList();
      expect(matches.map((m) => m.group(0)).toList(), ['1234', '5678']);

      final result = RuleEvaluator.resolveAmountMatch(matches, null, sms);
      expect(result, isNotNull);
      expect(result!.group(0), equals('1234'));
    });
  });
}
