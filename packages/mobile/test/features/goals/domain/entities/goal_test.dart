import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';

void main() {
  Goal goal({double target = 100, double saved = 0, DateTime? date}) => Goal(
    name: 'Laptop',
    targetAmount: target,
    savedAmount: saved,
    targetDate: date,
  );

  test('progress is the saved share, clamped to 0..1', () {
    expect(goal(saved: 50).progress, 0.5);
    expect(goal(saved: 150).progress, 1.0);
    expect(goal(target: 0).progress, 0);
  });

  test('remaining never goes below 0; reached at exactly the target', () {
    expect(goal(saved: 150).remaining, 0);
    expect(goal(saved: 30).remaining, 70);
    expect(goal(saved: 100).isReached, isTrue);
    expect(goal(saved: 99.99).isReached, isFalse);
  });

  test('monthsLeft counts whole calendar months', () {
    final now = DateTime(2026, 10, 24);

    expect(goal().monthsLeft(now), isNull);
    expect(goal(date: DateTime(2027, 1, 24)).monthsLeft(now), 3);
    expect(goal(date: DateTime(2027, 1, 23)).monthsLeft(now), 2);
    expect(goal(date: DateTime(2026, 5, 1)).monthsLeft(now), 0);
  });

  test('copyWith can clear the date and keeps it when omitted', () {
    final dated = goal(
      date: DateTime(2027, 1, 1),
    ).copyWith(monthlyContribution: 50);

    expect(dated.copyWith().targetDate, DateTime(2027, 1, 1));
    expect(dated.copyWith(targetDate: null).targetDate, isNull);
    expect(
      dated.copyWith(monthlyContribution: null).monthlyContribution,
      isNull,
    );
  });
}
