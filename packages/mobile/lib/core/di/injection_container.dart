import 'dart:async';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/database_seeder.dart';
import 'package:expense_tracker/core/database/transaction_runner.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/message_template_dao.dart';
import 'package:expense_tracker/core/database/daos/user_dao.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/goals_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/lifecycle/local_data_epoch.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';
import 'package:expense_tracker/core/sync/default_sync_registry.dart';
import 'package:expense_tracker/features/budgets/data/services/budget_name_repair.dart';
import 'package:expense_tracker/features/records/data/services/record_budget_link_repair.dart';
import 'package:expense_tracker/features/family/data/services/group_refresh_policy.dart';
import 'package:expense_tracker/features/recurring/application/recurring_auto_poster.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_local_datasource.dart';

import 'auth_module.dart';
import 'category_module.dart';
import 'record_module.dart';
import 'parsing_module.dart';
import 'report_module.dart';
import 'budget_module.dart';
import 'family_module.dart';
import 'recurring_module.dart';
import 'background_module.dart';
import 'settings_module.dart';
import 'export_module.dart';
import 'data_wipe_module.dart';
import 'sync_module.dart';
import 'dashboard_module.dart';
import 'ai_assistant_module.dart';
import 'receipt_scan_module.dart';
import 'goals_module.dart';
import 'onboarding_module.dart';
import 'support_module.dart';

final getIt = GetIt.instance;

Future<void> _ensureReady(String name, Future<void> Function() init) async {
  await init();

  return getIt.get<Future<void>>(instanceName: name);
}

Future<void> get criticalDependenciesReady =>
    _ensureReady('criticalReady', initCriticalDependencies);

Future<void> get featureDependenciesReady =>
    _ensureReady('featureReady', initFeatureDependencies);

void _registerDaoFactories() {
  getIt.registerFactory<RecordDao>(() => RecordDao(getIt<AppDatabase>()));
  getIt.registerFactory<CategoryDao>(() => CategoryDao(getIt<AppDatabase>()));
  getIt.registerFactory<MessageTemplateDao>(
    () => MessageTemplateDao(getIt<AppDatabase>()),
  );
  getIt.registerFactory<UserDao>(() => UserDao(getIt<AppDatabase>()));
  getIt.registerFactory<BudgetDao>(() => BudgetDao(getIt<AppDatabase>()));
  getIt.registerFactory<GoalsDao>(() => GoalsDao(getIt<AppDatabase>()));
  getIt.registerFactory<SyncQueueDao>(() => SyncQueueDao(getIt<AppDatabase>()));
  getIt.registerFactory<TransactionRunner>(
    () => DriftTransactionRunner(getIt<AppDatabase>()),
  );
}

Future<void> _autoPostRecurringAfterSync() async {
  if (!getIt.isRegistered<RecurringAutoPoster>()) return;
  await getIt<RecurringAutoPoster>().runAfterSync(
    pulled: getIt<SyncEngine>().lastPullSucceeded,
  );
}

Future<void> _resetRecurringAutoPost() {
  if (getIt.isRegistered<RecurringAutoPoster>()) {
    getIt<RecurringAutoPoster>().resetSession();
  }

  return Future.value();
}

Future<void> initCriticalDependencies() async {
  if (getIt.isRegistered<Future<void>>(instanceName: 'criticalReady')) return;

  criticalInitRunCount++;

  final completer = Completer<void>();
  getIt.registerSingleton<Future<void>>(
    completer.future,
    instanceName: 'criticalReady',
  );

  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(scopes: ['email', 'profile']),
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<LocalDataEpoch>(
    LocalDataEpoch.new,

    dispose: (epoch) => epoch.dispose(),
  );

  _registerDaoFactories();

  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<SyncTableRegistry>(
    () => createDefaultSyncRegistry(
      keepLocalBudgetNames: () =>
          getIt.isRegistered<BudgetNameRepair>() &&
          getIt<BudgetNameRepair>().isPending,

      keepLocalRecordBudgetLinks: () =>
          !getIt.isRegistered<RecordBudgetLinkRepair>() ||
          getIt<RecordBudgetLinkRepair>().isPending,
    ),
  );
  getIt.registerLazySingleton<SyncEngine>(
    () => SyncEngine(
      syncQueueDao: getIt<SyncQueueDao>(),
      apiClient: getIt<ApiClient>(),
      connectivity: getIt<ConnectivityService>(),
      registry: getIt<SyncTableRegistry>(),

      afterSyncTasks: [
        () async {
          if (getIt.isRegistered<BudgetNameRepair>()) {
            await getIt<BudgetNameRepair>().runOnce();
          }
        },
        () async {
          if (getIt.isRegistered<RecordBudgetLinkRepair>()) {
            await getIt<RecordBudgetLinkRepair>().runOnce();
          }
        },

        () async {
          if (getIt.isRegistered<GroupRefreshPolicy>()) {
            await getIt<GroupRefreshPolicy>().refreshIfDue();
          }
        },
        _autoPostRecurringAfterSync,
      ],

      beforeLocalWipeTasks: [
        () => getIt<BudgetNameRepair>().runOnce(),
        () => getIt<RecordBudgetLinkRepair>().runOnce(),
      ],
      stopTasks: [_resetRecurringAutoPost],

      isEnabled: () async =>
          !getIt.isRegistered<SettingsLocalDatasource>() ||
          (await getIt<SettingsLocalDatasource>().getSettings()).syncEnabled,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  initSettingsModule(getIt);
  initOnboardingCoreModule(getIt);
  initExportModule(getIt);
  initDataWipeModule(getIt);
  initSyncModule(getIt);

  initAuthModule(getIt);
  initCategoryModule(getIt);
  initRecordModule(getIt);
  initDashboardModule(getIt);
  initParsingModule(getIt);
  initReportModule(getIt);
  initAiAssistantModule(getIt);
  initReceiptScanModule(getIt);

  completer.complete();
}

Future<void> resetDatabaseInstance() async {
  if (getIt.isRegistered<AppDatabase>()) {
    final db = getIt<AppDatabase>();
    await db.clearAllTables();
    await DatabaseSeeder.seedInitialCategories(db);
  }

  await TokenStorage.clearSyncState();
}

@visibleForTesting
int criticalInitRunCount = 0;

@visibleForTesting
int featureInitRunCount = 0;

Future<void> initFeatureDependencies() async {
  if (getIt.isRegistered<Future<void>>(instanceName: 'featureReady')) return;

  featureInitRunCount++;

  final completer = Completer<void>();
  getIt.registerSingleton<Future<void>>(
    completer.future,
    instanceName: 'featureReady',
  );

  try {
    initBudgetModule(getIt);
    initFamilyModule(getIt);
    initRecurringModule(getIt);
    initGoalsModule(getIt);
    initOnboardingFeatureModule(getIt);
    initSupportModule(getIt);
    initBackgroundModule(getIt);
    completer.complete();
  } catch (e, s) {
    completer.completeError(e, s);
    rethrow;
  }
}

Future<void> initDependencies() async {
  await initCriticalDependencies();
  await initFeatureDependencies();
}
