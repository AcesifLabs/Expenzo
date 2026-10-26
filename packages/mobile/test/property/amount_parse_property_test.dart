import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/amount_match_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

typedef _Rendering = ({
  int cents,
  String prefix,
  int grouping,
  bool bangla,
  bool trailingDot,
});

const _prefixes = [
  '',
  'Tk.',
  'Tk ',
  'TK.',
  'BDT ',
  'BDT',
  'Rs.',
  'Rs ',
  'INR ',
  '৳',
  '৳ ',
  'USD ',
];

String _render(_Rendering r) {
  final whole = (r.cents ~/ 100).toString();
  final fraction = (r.cents % 100).toString().padLeft(2, '0');
  final digits = switch (r.grouping) {
    1 => grouped(whole, indian: false),
    2 => grouped(whole, indian: true),
    _ => whole,
  };
  final number = '$digits.$fraction${r.trailingDot ? '.' : ''}';

  return '${r.prefix}${r.bangla ? banglaDigits(number) : number}';
}

void main() {
  final renderings =
      combine5(
        positiveCents(),
        constantFrom(_prefixes),
        integer(min: 0, max: 2),
        boolean(),
        boolean(),
      ).map(
        (v) => (
          cents: v.$1,
          prefix: v.$2,
          grouping: v.$3,
          bangla: v.$4,
          trailingDot: v.$5,
        ),
      );

  property('any rendering of an amount reads back as that amount', () {
    forAll(renderings, maxExamples: propertyTrials, (r) {
      expect(parseResolvedAmount(_render(r)), r.cents / 100);
    });
  });

  property('any text gives null or a usable amount, and never throws', () {
    forAll(smsNoise(), maxExamples: propertyTrials, (text) {
      final amount = parseResolvedAmount(text);
      if (amount == null) return;
      expect(amount.isFinite, isTrue);
      expect(amount, greaterThan(0));
      expect(amount, lessThanOrEqualTo(AppConstants.maxAmount));
    });
  });
}
