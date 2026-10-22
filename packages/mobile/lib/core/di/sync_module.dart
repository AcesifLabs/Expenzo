import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/sync/sync_outcome_store.dart';
import 'package:expense_tracker/features/sync/data/repositories/sync_overview_repository_impl.dart';
import 'package:expense_tracker/features/sync/data/services/sync_outcome_reader.dart';
import 'package:expense_tracker/features/sync/domain/repositories/sync_overview_repository.dart';
import 'package:expense_tracker/features/sync/domain/usecases/get_sync_overview.dart';
import 'package:expense_tracker/features/sync/domain/usecases/sync_now.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_bloc.dart';

/// Needs the sync engine and queue from the critical dependencies.
void initSyncModule(GetIt getIt) {
  getIt.registerLazySingleton<SyncOverviewRepository>(
    () => SyncOverviewRepositoryImpl(
      engine: getIt<SyncEngine>(),
      queue: getIt<SyncQueueDao>(),
      outcomes: const SyncOutcomeReader(
        hasToken: TokenStorage.hasToken,
        lastSuccessfulSyncAt: SyncOutcomeStore.getLastSuccessfulSyncAt,
        lastFailedSyncAt: SyncOutcomeStore.getLastFailedSyncAt,
        consecutiveFailures: SyncOutcomeStore.getConsecutiveSyncFailures,
      ),
    ),
  );

  getIt.registerLazySingleton(
    () => GetSyncOverview(getIt<SyncOverviewRepository>()),
  );
  getIt.registerLazySingleton(() => SyncNow(getIt<SyncOverviewRepository>()));

  getIt.registerFactory(
    () => SyncScreenBloc(
      getOverview: getIt<GetSyncOverview>(),
      syncNow: getIt<SyncNow>(),
      repository: getIt<SyncOverviewRepository>(),
    ),
  );
}
