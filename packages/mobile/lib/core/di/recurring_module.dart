import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:expense_tracker/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/get_recurring_list.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/create_recurring.dart'
    as create_uc;
import 'package:expense_tracker/features/recurring/domain/usecases/update_recurring.dart'
    as update_uc;
import 'package:expense_tracker/features/recurring/domain/usecases/delete_recurring.dart'
    as delete_uc;
import 'package:expense_tracker/features/recurring/domain/usecases/process_recurring.dart'
    as process_uc;
import 'package:expense_tracker/core/database/transaction_runner.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/post_due_recurring.dart';
import 'package:expense_tracker/features/recurring/application/recurring_auto_poster.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/data/services/shared_prefs_recurring_reminder_log.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/send_recurring_reminders.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void initRecurringModule(GetIt getIt) {
  getIt.registerLazySingleton<RecurringLocalDatasource>(
    () => RecurringLocalDatasourceImpl(
      recurringDao: getIt<AppDatabase>().recurringDao,
    ),
  );
  getIt.registerLazySingleton<RecurringRepository>(
    () => RecurringRepositoryImpl(
      localDatasource: getIt<RecurringLocalDatasource>(),
      syncQueueDao: getIt<SyncQueueDao>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetRecurringList(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => create_uc.CreateRecurring(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => update_uc.UpdateRecurring(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => delete_uc.DeleteRecurring(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => process_uc.ProcessRecurring(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => PostDueRecurring(
      processRecurring: getIt<process_uc.ProcessRecurring>(),
      recordRepository: getIt<RecordRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
      getCategories: getIt<GetCategories>(),
      transactionRunner: getIt<TransactionRunner>(),
    ),
  );
  getIt.registerLazySingleton(
    () => RecurringAutoPoster(
      getSettings: getIt<GetSettings>(),
      postDueRecurring: getIt<PostDueRecurring>(),
      isSignedIn: TokenStorage.hasToken,
      // Auto-posted expenses raise budget alerts like a manual save.
      afterPost: () async {
        if (getIt.isRegistered<CheckBudgetAlerts>()) {
          await getIt<CheckBudgetAlerts>()();
        }
      },
    ),
  );
  getIt.registerLazySingleton<RecurringReminderLog>(
    () => SharedPrefsRecurringReminderLog(getIt<SharedPreferences>()),
  );
  // NotificationService is registered by initBudgetModule, which runs first.
  getIt.registerLazySingleton(
    () => SendRecurringReminders(
      getRecurringList: getIt<GetRecurringList>(),
      getSettings: getIt<GetSettings>(),
      notificationService: getIt<NotificationService>(),
      log: getIt<RecurringReminderLog>(),
    ),
  );
  getIt.registerFactory<RecurringBloc>(
    () => RecurringBloc(
      getRecurringList: getIt<GetRecurringList>(),
      createRecurring: getIt<create_uc.CreateRecurring>(),
      updateRecurring: getIt<update_uc.UpdateRecurring>(),
      deleteRecurring: getIt<delete_uc.DeleteRecurring>(),
      postDueRecurring: getIt<PostDueRecurring>(),
    ),
  );
}
