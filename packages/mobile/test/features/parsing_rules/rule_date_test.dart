import 'package:expense_tracker/features/parsing_rules/domain/entities/date_order.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/rule_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('day/month (the default)', () {
    const cases = {
      '05/10/2026': (2026, 10, 5),
      '25/10/2026': (2026, 10, 25),
      '25-10-2026': (2026, 10, 25),
      '5.10.2026': (2026, 10, 5),
      '05/10/26': (2026, 10, 5),
      '29/02/2028': (2028, 2, 29),
    };
    cases.forEach((text, ymd) {
      test(text, () {
        final (y, m, d) = ymd;
        expect(parseRuleDate(text, DateOrder.dmy), DateTime(y, m, d));
      });
    });
  });

  test('month/day reads the first number as the month', () {
    expect(parseRuleDate('05/10/2026', DateOrder.mdy), DateTime(2026, 5, 10));
    expect(parseRuleDate('10/25/2026', DateOrder.mdy), DateTime(2026, 10, 25));
  });

  group('month names ignore the date order', () {
    for (final text in [
      '05-Oct-2026',
      '05-OCT-26',
      '5 Oct 2026',
      '05 October 2026',
    ]) {
      test(text, () {
        expect(parseRuleDate(text, DateOrder.mdy), DateTime(2026, 10, 5));
      });
    }
  });

  test('year first is read as year-month-day', () {
    expect(parseRuleDate('2026-10-05', DateOrder.mdy), DateTime(2026, 10, 5));
    expect(parseRuleDate('2026/10/05', DateOrder.dmy), DateTime(2026, 10, 5));
  });

  group('days that do not exist are null, not rolled over', () {
    for (final text in [
      '31/02/2026',
      '29/02/2027',
      '00/10/2026',
      '10/13/2026',
      '05-Foo-2026',
    ]) {
      test(text, () => expect(parseRuleDate(text, DateOrder.dmy), isNull));
    }
  });

  test('a date inside longer text is found', () {
    expect(
      parseRuleDate('on 05-Oct-2026 at 10:15', DateOrder.dmy),
      DateTime(2026, 10, 5),
    );
  });
}
