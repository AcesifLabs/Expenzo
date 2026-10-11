import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:expense_tracker/features/budgets/data/services/budget_name_repair.dart';
import 'package:expense_tracker/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/create_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/update_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/delete_budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_transactions.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/budgets/data/services/shared_prefs_budget_alert_log.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

void initBudgetModule(GetIt getIt) {
  getIt.registerLazySingleton<BudgetLocalDatasource>(
    () => BudgetLocalDatasourceImpl(budgetDao: getIt<BudgetDao>()),
  );
  getIt.registerLazySingleton<BudgetRemoteDatasource>(
    () => BudgetRemoteDatasourceImpl(apiClient: getIt<ApiClient>()),
  );
  // Run by SyncEngine after each sync cycle (see injection_container).
  getIt.registerLazySingleton<BudgetNameRepair>(
    () => BudgetNameRepair(
      budgetDao: getIt<BudgetDao>(),
      remote: getIt<BudgetRemoteDatasource>(),
      prefs: getIt<SharedPreferences>(),
      currentUserId: () => getIt<FirebaseAuth>().currentUser?.uid,
    ),
  );
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(
      localDatasource: getIt<BudgetLocalDatasource>(),
      syncQueueDao: getIt<SyncQueueDao>(),
    ),
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
  getIt.registerLazySingleton(
    () => GetBudgetsWithProgress(
      budgetRepository: getIt<BudgetRepository>(),
      recordRepository: getIt<RecordRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetBudgetTransactions(
      budgetRepository: getIt<BudgetRepository>(),
      recordRepository: getIt<RecordRepository>(),
    ),
  );
  // Budget alerts (Settings → Budget alerts).
  getIt.registerLazySingleton<NotificationService>(NotificationService.new);
  getIt.registerLazySingleton<BudgetAlertLog>(
    () => SharedPrefsBudgetAlertLog(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton(
    () => CheckBudgetAlerts(
      getBudgetsWithProgress: getIt<GetBudgetsWithProgress>(),
      getSettings: getIt<GetSettings>(),
      notificationService: getIt<NotificationService>(),
      alertLog: getIt<BudgetAlertLog>(),
    ),
  );
  getIt.registerFactory<BudgetBloc>(
    () => BudgetBloc(
      getBudgets: getIt<GetBudgets>(),
      createBudget: getIt<CreateBudget>(),
      updateBudget: getIt<UpdateBudget>(),
      deleteBudget: getIt<DeleteBudget>(),
      getBudgetsWithProgress: getIt<GetBudgetsWithProgress>(),
      getBudgetTransactions: getIt<GetBudgetTransactions>(),
    ),
  );
}
