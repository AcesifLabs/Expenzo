import 'dart:async';
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

bool _featureDependenciesRegistered = false;
final _featureDependenciesCompleter = Completer<void>();

Future<void> get featureDependenciesReady =>
    _featureDependenciesCompleter.future;

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

/// Registers ONLY the dependencies needed for the first visible screen
/// (Auth + Database + Categories + Records + Settings). Returns immediately so
/// the splash screen can render without waiting for the full DI graph.
Future<void> initCriticalDependencies() async {
  // ── Infrastructure ──
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

  // DAOs
  _registerDaoFactories();

  // API & Sync
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

  // ── Settings (needed immediately for theme) ──
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  initSettingsModule(getIt);

  // ── Feature Modules (Critical) ──
  initAuthModule(getIt);
  initCategoryModule(getIt);
  initRecordModule(getIt);
  initDashboardModule(getIt);
  initParsingModule(getIt);
  initReportModule(getIt);
}

Future<void> resetDatabaseInstance() async {
  if (getIt.isRegistered<AppDatabase>()) {
    final db = getIt<AppDatabase>();
    await db.clearAllTables();
    await DatabaseSeeder.seedInitialCategories(db);
  }
  // Reset sync cursor so next pull uses epoch (full re-sync)
  await TokenStorage.clearSyncState();
}

/// Registers feature-level dependencies (Budgets).
/// Called in the background after the first frame renders.
/// Safe to call multiple times — will only register once.
Future<void> initFeatureDependencies() async {
  if (_featureDependenciesRegistered) return;
  _featureDependenciesRegistered = true;

  try {
    initBudgetModule(getIt);
    initRecurringModule(getIt);
    _featureDependenciesCompleter.complete();
  } catch (e, s) {
    _featureDependenciesCompleter.completeError(e, s);
    rethrow;
  }
}

/// Backwards-compatible call that registers everything at once.
/// Used by integration tests or scenarios where layered init isn't needed.
Future<void> initDependencies() async {
  await initCriticalDependencies();
  await initFeatureDependencies();
}
