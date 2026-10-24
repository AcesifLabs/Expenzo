import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/family/domain/services/budget_access.dart';

/// The app's [BudgetAccess], or one with no group where the Family module
/// is not registered (tests of other screens).
BudgetAccess budgetAccess() => di.getIt.isRegistered<BudgetAccess>()
    ? di.getIt<BudgetAccess>()
    : BudgetAccess.none();
