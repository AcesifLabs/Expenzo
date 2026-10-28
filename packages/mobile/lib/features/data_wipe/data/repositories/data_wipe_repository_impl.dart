import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

import '../../domain/entities/local_data_summary.dart';
import '../../domain/repositories/data_wipe_repository.dart';
import '../datasources/data_wipe_local_datasource.dart';
import '../datasources/data_wipe_remote_datasource.dart';
import '../services/data_wipe_hooks.dart';

class DataWipeRepositoryImpl implements DataWipeRepository {
  final DataWipeLocalDatasource localDatasource;
  final DataWipeRemoteDatasource remoteDatasource;
  final SettingsRepository settingsRepository;
  final DataWipeHooks hooks;

  const DataWipeRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.settingsRepository,
    required this.hooks,
  });

  @override
  Future<Either<Failure, LocalDataSummary>> countData() async {
    try {
      return Right(await localDatasource.countData());
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<bool> isSignedIn() => hooks.isSignedIn();

  @override
  Future<Either<Failure, Unit>> wipeLocalData() async {
    try {
      await localDatasource.wipeLocalData();
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
    await _bestEffort('Settings reset', _resetSettings);
    await _bestEffort('Cancelling scheduled work', hooks.cancelScheduledWork);
    await _bestEffort('Clearing local prefs', hooks.clearLocalPrefs);

    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteAllData() async {
    var serverCleared = false;
    try {
      final signedIn = await hooks.isSignedIn();

      await hooks.pauseSync();
      if (signedIn) {
        await remoteDatasource.clearSyncedData();
        serverCleared = true;
      }

      return await wipeLocalData();
    } on AuthException catch (e, s) {
      return _failed(e.toFailure(), e, s);
    } on NetworkException catch (e, s) {
      return _failed(e.toFailure(), e, s);
    } on ServerException catch (e, s) {
      return _failed(e.toFailure(), e, s);
    } catch (e, s) {
      return _failed(CacheFailure(message: e.toString()), e, s);
    } finally {
      await _resumeSync(serverCleared: serverCleared);
    }
  }

  Future<void> _resumeSync({required bool serverCleared}) async {
    if (serverCleared) {
      await _bestEffort('Resetting sync state', hooks.resetSyncState);
    }
    unawaited(_bestEffort('Resuming sync', hooks.resumeSync));
  }

  Future<void> _resetSettings() async {
    final result = await settingsRepository.resetSettings();
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) throw CacheException(message: failure.message);
  }

  static Future<void> _bestEffort(
    String step,
    Future<Object?> Function() run,
  ) async {
    try {
      await run();
    } catch (e, s) {
      appLogger.error('$step failed', e, s);
    }
  }

  static Either<Failure, Unit> _failed(
    Failure failure,
    Object error,
    StackTrace stack,
  ) {
    appLogger.error('Delete all data failed', error, stack);

    return Left(failure);
  }
}
