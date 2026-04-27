import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/daos/expense_dao.dart';
import 'package:expense_tracker/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:expense_tracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/add_expense.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/create_expense_from_parsed.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/create_expenses_from_parsed_list.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/delete_expense.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/update_expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';

void initExpenseModule(GetIt getIt) {
  getIt.registerLazySingleton<ExpenseLocalDatasource>(
    () => ExpenseLocalDatasourceImpl(expenseDao: getIt<ExpenseDao>()),
  );
  getIt.registerLazySingleton<ExpenseRepository>(
    () =>
        ExpenseRepositoryImpl(localDatasource: getIt<ExpenseLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => GetExpenses(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => AddExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => UpdateExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(() => DeleteExpense(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton(
    () => CreateExpenseFromParsed(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateExpensesFromParsedList(getIt<ExpenseRepository>()),
  );
  getIt.registerFactory<ExpenseBloc>(
    () => ExpenseBloc(
      getExpenses: getIt<GetExpenses>(),
      addExpense: getIt<AddExpense>(),
      updateExpense: getIt<UpdateExpense>(),
      deleteExpense: getIt<DeleteExpense>(),
      expenseRepository: getIt<ExpenseRepository>(),
    ),
  );
}
