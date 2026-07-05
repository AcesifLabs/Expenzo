import 'dart:async';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/database_seeder.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/pending_recurring_dao.dart';
import 'package:expense_tracker/core/database/daos/message_template_dao.dart';
import 'package:expense_tracker/core/database/daos/user_dao.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';
import 'package:expense_tracker/core/sync/default_sync_registry.dart';

import 'auth_module.dart';
import 'category_module.dart';
import 'record_module.dart';
import 'parsing_module.dart';
import 'report_module.dart';
import 'budget_module.dart';
import 'recurring_module.dart';
import 'settings_module.dart';
import 'dashboard_module.dart';

final getIt = GetIt.instance;

/// Returns the future registered for [name], running [init] first if the
/// future has not yet been registered. This makes the dependent getter
/// safe to `await` from any caller regardless of whether the init has
/// been scheduled yet — the underlying init function is idempotent and
/// will only run once.
Future<void> _ensureReady(String name, Future<void> Function() init) async {
  await init();

  return getIt.get<Future<void>>(instanceName: name);
}

/// Safe to `await` from anywhere. If [initCriticalDependencies] has not
/// been run yet, this getter runs it (and awaits the result) before
/// returning the future.
Future<void> get criticalDependenciesReady =>
    _ensureReady('criticalReady', initCriticalDependencies);

/// Safe to `await` from any widget, regardless of when
/// [initFeatureDependencies] was scheduled. The underlying
/// [initFeatureDependencies] is idempotent and will be run on the first
/// call if it has not been run yet.
Future<void> get featureDependenciesReady =>
    _ensureReady('featureReady', initFeatureDependencies);

void _registerDaoFactories() {
  getIt.registerFactory<RecordDao>(() => RecordDao(getIt<AppDatabase>()));
  getIt.registerFactory<CategoryDao>(() => CategoryDao(getIt<AppDatabase>()));
  getIt.registerFactory<PendingRecurringDao>(
    () => PendingRecurringDao(getIt<AppDatabase>()),
  );
  getIt.registerFactory<MessageTemplateDao>(
    () => MessageTemplateDao(getIt<AppDatabase>()),
  );
  getIt.registerFactory<UserDao>(() => UserDao(getIt<AppDatabase>()));
  getIt.registerFactory<BudgetDao>(() => BudgetDao(getIt<AppDatabase>()));
  getIt.registerFactory<SyncQueueDao>(() => SyncQueueDao(getIt<AppDatabase>()));
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
    () => GoogleSignIn(
      scopes: [
        'email',
        'profile',
        'https://www.googleapis.com/auth/gmail.readonly',
      ],
    ),
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  _registerDaoFactories();

  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<SyncTableRegistry>(
    () => createDefaultSyncRegistry(),
  );
  getIt.registerLazySingleton<SyncEngine>(
    () => SyncEngine(
      syncQueueDao: getIt<SyncQueueDao>(),
      apiClient: getIt<ApiClient>(),
      connectivity: getIt<ConnectivityService>(),
      registry: getIt<SyncTableRegistry>(),
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  initSettingsModule(getIt);

  initAuthModule(getIt);
  initCategoryModule(getIt);
  initRecordModule(getIt);
  initDashboardModule(getIt);
  initParsingModule(getIt);
  initReportModule(getIt);

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

/// Counts the number of times [initCriticalDependencies] has actually
/// run (i.e. the `isRegistered` guard did not short-circuit). Tests
/// reset this in `setUp` and assert it bumps after `GetIt.I.reset()`,
/// which pins the "run-once per GetIt registration" contract the
/// dartdoc on [criticalDependenciesReady] promises — the guard
/// short-circuits as long as the completer stays registered.
@visibleForTesting
int criticalInitRunCount = 0;

/// Counts the number of times [initFeatureDependencies] has actually
/// run the module inits (i.e. the `isRegistered` guard did not
/// short-circuit). Tests reset this in `setUp` and assert it stays at
/// 1 after multiple getter calls, which pins the run-once contract the
/// dartdoc on [featureDependenciesReady] promises.
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
    initRecurringModule(getIt);
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
