import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/features/budgets/domain/budget_plan.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

void main() {
  double cents(double v) => (v * 100).roundToDouble() / 100;

  PlanRow row(String name, double amount, {String? id, bool savings = false}) =>
      PlanRow(
        key: id ?? name,
        budgetId: id,
        name: name,
        amount: amount,
        isSavings: savings,
      );

  Budget budget(String id, String name, double amount) => Budget(
    id: id,
    name: name,
    amount: amount,
    period: BudgetPeriod.monthly,
    startDate: DateTime(2026, 1, 1),
  );

  group('suggestedPlanRows', () {
    test('splits 50/30/20 with Savings marked', () {
      final rows = suggestedPlanRows(3775);

      expect(rows.map((r) => r.name), ['Needs', 'Wants', 'Savings']);
      expect(rows.map((r) => r.amount), [1887.5, 1132.5, 755]);
      expect(rows.map((r) => r.isSavings), [false, false, true]);
      expect(rows.map((r) => r.budgetId), everyElement(isNull));
      expect(rows.map((r) => r.key).toSet(), hasLength(3));
    });

    test('rows add up to the base after rounding', () {
      for (final base in [1000.0, 3333.33, 1234.57, 99.99, 1000.01]) {
        expect(planTotal(suggestedPlanRows(base)), base, reason: '$base');
      }
    });

    test('names follow the app language', () {
      LocaleSettings.setLocaleSync(AppLocale.bn);
      addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

      expect(suggestedPlanRows(100).first.name, 'প্রয়োজন');
    });

    test('no base gives rows at 0', () {
      expect(suggestedPlanRows(0).map((r) => r.amount), [0, 0, 0]);
      expect(suggestedPlanRows(-50).map((r) => r.amount), [0, 0, 0]);
    });
  });

  group('remaining and savings', () {
    final rows = [row('A', 600), row('B', 300.5)];

    test('remaining can go below 0', () {
      expect(planRemaining(1000, rows), 99.5);
      expect(planRemaining(800, rows), -100.5);
    });

    test('savings uses the Savings row, even renamed', () {
      final withSavings = [...rows, row('Rainy day', 50, savings: true)];

      expect(planSavings(5000, withSavings), 50);
    });

    test('savings falls back to the remainder, never below 0', () {
      expect(planSavings(1000, rows), 99.5);
      expect(planSavings(800, rows), 0);
    });
  });

  group('rescaleToBase', () {
    test('keeps proportions and sums to the base exactly', () {
      final scaled = rescaleToBase([
        row('A', 1),
        row('B', 1),
        row('C', 1),
      ], 1000.01);

      expect(planTotal(scaled), 1000.01);
      expect(scaled.map((r) => r.amount), [333.33, 333.34, 333.34]);
    });

    test('a row at 0 never goes negative', () {
      for (final base in [0.03, 100.01, 1000.01]) {
        final scaled = rescaleToBase([
          row('A', 1),
          row('B', 1),
          row('C', 0),
        ], base);

        expect(scaled.last.amount, 0, reason: '$base');
        expect(scaled.every((r) => r.amount >= 0), isTrue, reason: '$base');
        expect(planTotal(scaled), base, reason: '$base');
      }
    });

    test('scales by current share', () {
      final scaled = rescaleToBase([row('A', 300), row('B', 100)], 2000);

      expect(scaled.map((r) => r.amount), [1500, 500]);
    });

    test('all-zero rows share the base evenly', () {
      final scaled = rescaleToBase([row('A', 0), row('B', 0)], 100);

      expect(scaled.map((r) => r.amount), [50, 50]);
    });

    test('keeps names, keys and the savings flag', () {
      final scaled = rescaleToBase([row('S', 10, savings: true)], 40);

      expect(scaled.single, row('S', 40, savings: true));
    });

    test('no rows or no base leaves rows alone', () {
      final rows = [row('A', 5)];

      expect(rescaleToBase(const [], 100), isEmpty);
      expect(rescaleToBase(rows, 0), rows);
    });
  });

  group('validatePlan', () {
    test('valid rows have no errors', () {
      expect(
        validatePlan([row('A', 1), row('B', 2)], allowZero: false),
        isEmpty,
      );
    });

    test('flags name problems', () {
      final errors = validatePlan([
        row('blank', 1).copyWith(name: '  '),
        row('reserved', 1).copyWith(name: AppConstants.defaultBudgetName),
        row(
          'long',
          1,
        ).copyWith(name: 'x' * (AppConstants.budgetNameMaxLength + 1)),
      ], allowZero: false);

      expect(errors['blank'], {PlanRowError.nameRequired});
      expect(errors['reserved'], {PlanRowError.nameReserved});
      expect(errors['long'], {PlanRowError.nameTooLong});
    });

    test('duplicates ignore case and spaces, on every copy', () {
      final errors = validatePlan([
        row('Food', 1),
        row('x', 1).copyWith(name: ' food '),
        row('Rent', 1),
      ], allowZero: false);

      expect(errors.keys, unorderedEquals(['Food', 'x']));
      expect(errors['Food'], {PlanRowError.nameDuplicate});
    });

    test('zero amounts depend on allowZero; negatives never pass', () {
      final rows = [row('Zero', 0), row('Neg', -1)];

      expect(validatePlan(rows, allowZero: false).keys, ['Zero', 'Neg']);
      expect(validatePlan(rows, allowZero: true).keys, ['Neg']);
      expect(validatePlan(rows, allowZero: true)['Neg'], {
        PlanRowError.amountInvalid,
      });
    });
  });

  group('diffPlan', () {
    final now = DateTime(2026, 10, 30, 14);
    final current = [
      budget('1', 'Rent', 1000),
      budget('2', 'Food', 400),
      budget('3', 'Fun', 100),
      budget('4', 'Gone', 50),
    ];

    test('sorts rows into create, update and delete', () {
      final changes = diffPlan(current, [
        row('Rent', 1000, id: '1'),
        row('Groceries ', 400, id: '2'),
        row('Fun', 150, id: '3'),
        row('Travel', 200),
        row('Empty', 0),
      ], now);

      expect(changes.toUpdate, [
        current[1].copyWith(name: 'Groceries'),
        current[2].copyWith(amount: 150),
      ]);
      expect(changes.toDelete, [current[3]]);
      expect(changes.toCreate, [
        Budget(
          name: 'Travel',
          amount: 200,
          period: BudgetPeriod.monthly,
          startDate: DateTime(2026, 10, 1),
        ),
      ]);
    });

    test('unchanged rows give no changes', () {
      final rows = [for (final b in current) planRowFor(b)];

      expect(diffPlan(current, rows, now).isEmpty, isTrue);
    });
  });

  test('planRowFor keys a row by its budget id', () {
    final r = planRowFor(budget('9', 'Rent', 10));

    expect(r, row('Rent', 10, id: '9'));
    expect(cents(r.amount), 10);
  });
}
