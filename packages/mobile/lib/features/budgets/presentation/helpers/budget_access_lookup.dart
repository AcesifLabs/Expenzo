import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/family/domain/services/budget_access.dart';

BudgetAccess budgetAccess() => di.getIt.isRegistered<BudgetAccess>()
    ? di.getIt<BudgetAccess>()
    : BudgetAccess.none();
