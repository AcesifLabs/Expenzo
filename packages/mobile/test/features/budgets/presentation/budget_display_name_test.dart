import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_display_name.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => LocaleSettings.setLocale(AppLocale.en));

  test('shows a real name as typed', () {
    expect(budgetDisplayName('Groceries'), 'Groceries');
  });

  test('shows the placeholder in the app language', () {
    LocaleSettings.setLocale(AppLocale.bn);

    expect(
      budgetDisplayName(AppConstants.defaultBudgetName),
      t.budgets.unnamed,
    );
    expect(budgetDisplayName(''), t.budgets.unnamed);
    expect(t.budgets.unnamed, isNot(AppConstants.defaultBudgetName));
  });
}
