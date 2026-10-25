import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

void main() {
  property('a prefilled amount field reads back as the stored amount', () {
    forAll(positiveCents(), maxExamples: propertyTrials, (cents) {
      final amount = cents / 100;
      expect(
        parseAmountInput(CurrencyFormatter.formatInput(amount)),
        roundMoney(amount),
      );
    });
  });

  property('typed grouping and Bangla digits read the same amount', () {
    forAll(
      combine3(positiveCents(), boolean(), boolean()),
      maxExamples: propertyTrials,
      (v) {
        final (cents, indian, bangla) = v;
        final whole = grouped('${cents ~/ 100}', indian: indian);
        final text = '$whole.${(cents % 100).toString().padLeft(2, '0')}';
        expect(
          parseAmountInput(bangla ? banglaDigits(text) : text),
          cents / 100,
        );
      },
    );
  });

  property('an amount near zero is never shown as -0', () {
    forAll(float(min: -0.004, max: 0.004), maxExamples: propertyTrials, (
      amount,
    ) {
      expect(CurrencyFormatter.formatInput(roundMoney(amount)), '0');
      expect(
        CurrencyFormatter.format(roundMoney(amount)),
        isNot(contains('-')),
      );
    });
  });
}
