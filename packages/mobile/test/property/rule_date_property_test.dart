import 'package:expense_tracker/features/parsing_rules/domain/entities/date_order.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/rule_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'generators.dart';

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// [date] written the ways rules see dates, read in [order] where it
/// matters.
List<String> _renderings(DateTime date, DateOrder order) {
  final day = _two(date.day);
  final month = _two(date.month);
  final year = '${date.year}';
  final shortYear = year.substring(2);
  final numeric = order == DateOrder.dmy ? '$day/$month' : '$month/$day';

  return [
    '$numeric/$year',
    '$numeric/$shortYear',
    '${numeric.replaceAll('/', '-')}-$year',
    '$day-${_monthNames[date.month - 1]}-$year',
    '${date.day} ${_monthNames[date.month - 1]} $shortYear',
    '$year-$month-$day',
  ];
}

void main() {
  final orders = constantFrom(DateOrder.values);

  property('a written date reads back as the same day', () {
    forAll(combine2(anyDateTime(), orders), maxExamples: propertyTrials, (v) {
      final (at, order) = v;
      final day = DateTime(at.year, at.month, at.day);
      for (final text in _renderings(day, order)) {
        expect(parseRuleDate('Paid on $text.', order), day, reason: text);
      }
    });
  });

  property('a day that does not exist reads as null', () {
    final impossible = combine3(
      integer(min: 2000, max: 2099),
      integer(min: 1, max: 12),
      integer(min: 29, max: 31),
    ).filter((v) => DateTime(v.$1, v.$2, v.$3).day != v.$3);

    forAll(combine2(impossible, orders), maxExamples: propertyTrials, (v) {
      final ((year, month, day), order) = v;
      final numeric = order == DateOrder.dmy
          ? '${_two(day)}/${_two(month)}'
          : '${_two(month)}/${_two(day)}';
      expect(parseRuleDate('on $numeric/$year', order), isNull);
      expect(
        parseRuleDate('on ${_two(day)}-${_monthNames[month - 1]}-$year', order),
        isNull,
      );
    });
  });

  property('any text gives a date or null, and never throws', () {
    forAll(combine2(smsNoise(), orders), maxExamples: propertyTrials, (v) {
      parseRuleDate(v.$1, v.$2);
    });
  });
}
