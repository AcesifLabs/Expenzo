import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../database/app_database.dart';
import '../database/daos/sync_queue_dao.dart';
import '../database/database_file.dart';
import '../database/database_seeder.dart';
import '../api/token_storage.dart';
import '../di/injection_container.dart' as di;
import '../logger/app_logger.dart';

class BootstrapService {
  final Future<void> Function() remountRoot;

  BootstrapService({required this.remountRoot});

  Future<void> seedInitialData() async {
    try {
      final db = di.getIt<AppDatabase>();
      await DatabaseSeeder.seedInitialCategories(db);
    } catch (e, s) {
      appLogger.error('DatabaseSeeder failed (non-fatal)', e, s);
    }
    try {
      await di.getIt<SyncQueueDao>().deleteSentBefore(clock.now());
    } catch (e, s) {
      appLogger.error('Pruning sent sync changes failed (non-fatal)', e, s);
    }
  }

  void restart() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      SystemNavigator.pop();

      return;
    }

    unawaited(retry());
  }

  Future<void> retry() async {
    await _closeDatabase();
    await GetIt.I.reset().catchError((Object _) => null);
    GetIt.I.registerSingleton<BootstrapService>(this);
    await remountRoot();
  }

  Future<void> resetLocalData({File? file}) async {
    await _closeDatabase();
    await setDatabaseFileAside(file ?? await databaseFile());
    await TokenStorage.clearSyncState();
    await retry();
  }

  Future<void> _closeDatabase() async {
    if (!GetIt.I.isRegistered<AppDatabase>()) return;
    try {
      await GetIt.I<AppDatabase>().close();
    } catch (e, s) {
      appLogger.error('Closing the database before a restart failed', e, s);
    }
  }
}
