import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expense_tracker/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/create_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/update_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/delete_budget.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';

void initBudgetModule(GetIt getIt) {
  getIt.registerLazySingleton<BudgetDao>(() => BudgetDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<BudgetLocalDatasource>(
    () => BudgetLocalDatasourceImpl(budgetDao: getIt<BudgetDao>()),
  );
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(localDatasource: getIt<BudgetLocalDatasource>()),
  );
  getIt.registerLazySingleton(
    () => GetBudgets(repository: getIt<BudgetRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateBudget(repository: getIt<BudgetRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateBudget(repository: getIt<BudgetRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteBudget(repository: getIt<BudgetRepository>()),
  );
  getIt.registerFactory<BudgetBloc>(
    () => BudgetBloc(
      getBudgets: getIt<GetBudgets>(),
      createBudget: getIt<CreateBudget>(),
      updateBudget: getIt<UpdateBudget>(),
      deleteBudget: getIt<DeleteBudget>(),
    ),
  );
}
