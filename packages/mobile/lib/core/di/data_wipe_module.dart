import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/background/background_task_scheduler.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';
import 'package:expense_tracker/features/data_wipe/data/datasources/data_wipe_local_datasource.dart';
import 'package:expense_tracker/features/data_wipe/data/datasources/data_wipe_remote_datasource.dart';
import 'package:expense_tracker/features/data_wipe/data/repositories/data_wipe_repository_impl.dart';
import 'package:expense_tracker/features/data_wipe/data/services/data_wipe_hooks.dart';
import 'package:expense_tracker/features/data_wipe/data/services/local_data_prefs.dart';
import 'package:expense_tracker/features/data_wipe/domain/repositories/data_wipe_repository.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/delete_all_data.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/get_local_data_summary.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/wipe_local_data.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_bloc.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

/// Needs the settings repository, so it runs after `initSettingsModule`.
void initDataWipeModule(GetIt getIt) {
  getIt.registerLazySingleton<DataWipeLocalDatasource>(
    () => DataWipeLocalDatasourceImpl(
      db: getIt<AppDatabase>(),
      registry: getIt<SyncTableRegistry>(),
    ),
  );

  getIt.registerLazySingleton<DataWipeRemoteDatasource>(
    () => DataWipeRemoteDatasourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<DataWipeRepository>(
    () => DataWipeRepositoryImpl(
      localDatasource: getIt<DataWipeLocalDatasource>(),
      remoteDatasource: getIt<DataWipeRemoteDatasource>(),
      settingsRepository: getIt<SettingsRepository>(),
      hooks: DataWipeHooks(
        pauseSync: () => getIt<SyncEngine>().pause(),
        resumeSync: () => getIt<SyncEngine>().resume(),
        resetSyncState: TokenStorage.clearSyncState,
        cancelScheduledWork: () => cancelScheduledWork(getIt),
        clearLocalPrefs: () =>
            LocalDataPrefs(getIt<SharedPreferences>()).clear(),
        isSignedIn: TokenStorage.hasToken,
      ),
    ),
  );

  getIt.registerLazySingleton(
    () => GetLocalDataSummary(getIt<DataWipeRepository>()),
  );
  getIt.registerLazySingleton(() => WipeLocalData(getIt<DataWipeRepository>()));
  getIt.registerLazySingleton(() => DeleteAllData(getIt<DataWipeRepository>()));

  getIt.registerFactory(
    () => DeleteAllDataBloc(
      getSummary: getIt<GetLocalDataSummary>(),
      repository: getIt<DataWipeRepository>(),
      deleteAllData: getIt<DeleteAllData>(),
    ),
  );
}

/// Both live in feature deps, which may not be ready yet; resolved at call
/// time.
@visibleForTesting
Future<void> cancelScheduledWork(GetIt getIt) async {
  if (getIt.isRegistered<NotificationService>()) {
    await getIt<NotificationService>().cancelAll();
  }
  if (getIt.isRegistered<BackgroundTaskScheduler>()) {
    await getIt<BackgroundTaskScheduler>().cancelAll();
  }
}
