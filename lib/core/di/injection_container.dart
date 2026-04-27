import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/expense_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/pending_recurring_dao.dart';
import 'package:expense_tracker/core/database/daos/message_template_dao.dart';

import 'auth_module.dart';
import 'category_module.dart';
import 'expense_module.dart';
import 'parsing_module.dart';
import 'report_module.dart';
import 'budget_module.dart';
import 'settings_module.dart';

final getIt = GetIt.instance;

bool _featureDependenciesRegistered = false;
Completer<void>? _featureDependenciesCompleter;

Future<void> get featureDependenciesReady =>
    _featureDependenciesCompleter?.future ?? Future.value();

/// Registers ONLY the dependencies needed for the first visible screen
/// (Auth + Database + Categories + Expenses). Returns immediately so
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
  getIt.registerFactory<ExpenseDao>(() => ExpenseDao(getIt<AppDatabase>()));
  getIt.registerFactory<CategoryDao>(() => CategoryDao(getIt<AppDatabase>()));
  getIt.registerFactory<PendingRecurringDao>(
    () => PendingRecurringDao(getIt<AppDatabase>()),
  );
  getIt.registerFactory<MessageTemplateDao>(
    () => MessageTemplateDao(getIt<AppDatabase>()),
  );

  // ── Feature Modules (Critical) ──
  initAuthModule(getIt);
  initCategoryModule(getIt);
  initExpenseModule(getIt);
}

/// Registers feature-level dependencies (Scan, Email, Parsing, Reports,
/// Budgets, Templates). Called in the background after the first frame
/// renders. Safe to call multiple times — will only register once.
Future<void> initFeatureDependencies() async {
  if (_featureDependenciesRegistered) return;
  _featureDependenciesRegistered = true;
  _featureDependenciesCompleter = Completer<void>();

  try {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);

    initParsingModule(getIt);
    initReportModule(getIt);
    initBudgetModule(getIt);
    initSettingsModule(getIt);
    _featureDependenciesCompleter!.complete();
  } catch (e, s) {
    _featureDependenciesCompleter!.completeError(e, s);
    rethrow;
  }
}

/// Backwards-compatible call that registers everything at once.
/// Used by integration tests or scenarios where layered init isn't needed.
Future<void> initDependencies() async {
  await initCriticalDependencies();
  await initFeatureDependencies();
}
