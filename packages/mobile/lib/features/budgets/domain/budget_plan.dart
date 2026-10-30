import 'package:uuid/uuid.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/utils/budget_name.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'entities/budget.dart';
import 'entities/plan_changes.dart';
import 'entities/plan_row.dart';

enum PlanRowError {
  nameRequired,
  nameReserved,
  nameTooLong,
  nameDuplicate,
  amountInvalid,
}

PlanRow newPlanRow({String name = '', double amount = 0}) =>
    PlanRow(key: const Uuid().v4(), name: name, amount: amount);

PlanRow planRowFor(Budget budget) => PlanRow(
  key: budget.id ?? const Uuid().v4(),
  budgetId: budget.id,
  name: budget.name,
  amount: budget.amount,
);

/// The 50/30/20 starting point. Needs takes the rounding so the three
/// rows add up to [base].
List<PlanRow> suggestedPlanRows(double base) {
  final names = t.budgets.plan.names;
  final total = base > 0 ? roundMoney(base) : 0.0;
  final wants = roundMoney(total * AppConstants.wantsShare);
  final savings = roundMoney(total * AppConstants.savingsShare);

  return [
    newPlanRow(name: names.needs, amount: roundMoney(total - wants - savings)),
    newPlanRow(name: names.wants, amount: wants),
    PlanRow(
      key: const Uuid().v4(),
      name: names.savings,
      amount: savings,
      isSavings: true,
    ),
  ];
}

double planTotal(List<PlanRow> rows) =>
    roundMoney(rows.fold(0, (sum, row) => sum + row.amount));

double planRemaining(double base, List<PlanRow> rows) =>
    roundMoney(base - planTotal(rows));

/// The savings a goal can count on: the suggested Savings row if the user
/// kept it, otherwise whatever no row claims.
double planSavings(double base, List<PlanRow> rows) {
  for (final row in rows) {
    if (row.isSavings) return row.amount;
  }
  final remaining = planRemaining(base, rows);

  return remaining > 0 ? remaining : 0;
}

/// Scales every row so they keep their proportions and add up to [base].
/// Rows that are all 0 share it evenly. The largest row takes the
/// rounding, so no row can go below 0.
List<PlanRow> rescaleToBase(List<PlanRow> rows, double base) {
  if (rows.isEmpty || base <= 0) return rows;
  final total = planTotal(rows);
  final amounts = [
    for (final row in rows)
      roundMoney(base * (total > 0 ? row.amount / total : 1 / rows.length)),
  ];
  var largest = 0;
  for (final (index, amount) in amounts.indexed) {
    if (amount > amounts[largest]) largest = index;
  }
  amounts[largest] = roundMoney(
    amounts[largest] + base - amounts.fold(0.0, (sum, a) => sum + a),
  );

  return [
    for (final (index, row) in rows.indexed)
      row.copyWith(amount: amounts[index]),
  ];
}

Map<String, Set<PlanRowError>> validatePlan(
  List<PlanRow> rows, {
  required bool allowZero,
}) {
  final counts = <String, int>{};
  for (final row in rows) {
    final name = _nameKey(row.name);
    if (name.isNotEmpty) counts[name] = (counts[name] ?? 0) + 1;
  }
  final errors = <String, Set<PlanRowError>>{};
  for (final row in rows) {
    final rowErrors = {
      ?_nameError(row.name, counts),
      if (allowZero ? row.amount < 0 : row.amount <= 0)
        PlanRowError.amountInvalid,
    };
    if (rowErrors.isNotEmpty) errors[row.key] = rowErrors;
  }

  return errors;
}

PlanChanges diffPlan(List<Budget> current, List<PlanRow> rows, DateTime now) {
  final byId = {for (final budget in current) ?budget.id: budget};
  final keptIds = {for (final row in rows) ?row.budgetId};
  final toUpdate = <Budget>[];
  final toCreate = <Budget>[];
  for (final row in rows) {
    final existing = byId[row.budgetId];
    final name = row.name.trim();
    if (existing == null) {
      if (row.amount > 0) {
        toCreate.add(
          Budget(
            name: name,
            amount: row.amount,
            period: BudgetPeriod.monthly,
            startDate: DateTime(now.year, now.month, 1),
          ),
        );
      }
    } else if (existing.name != name || existing.amount != row.amount) {
      toUpdate.add(existing.copyWith(name: name, amount: row.amount));
    }
  }

  return PlanChanges(
    toCreate: toCreate,
    toUpdate: toUpdate,
    toDelete: [
      for (final budget in current)
        if (!keptIds.contains(budget.id)) budget,
    ],
  );
}

PlanRowError? _nameError(String raw, Map<String, int> counts) {
  final name = raw.trim();
  if (name.isEmpty) return PlanRowError.nameRequired;
  if (isPlaceholderBudgetName(name)) return PlanRowError.nameReserved;
  if (name.length > AppConstants.budgetNameMaxLength) {
    return PlanRowError.nameTooLong;
  }

  return (counts[_nameKey(raw)] ?? 0) > 1 ? PlanRowError.nameDuplicate : null;
}

String _nameKey(String name) => name.trim().toLowerCase();
