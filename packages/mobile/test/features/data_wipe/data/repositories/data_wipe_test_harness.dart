import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/sync/default_sync_registry.dart';
import 'package:expense_tracker/features/data_wipe/data/datasources/data_wipe_local_datasource.dart';
import 'package:expense_tracker/features/data_wipe/data/datasources/data_wipe_remote_datasource.dart';
import 'package:expense_tracker/features/data_wipe/data/repositories/data_wipe_repository_impl.dart';
import 'package:expense_tracker/features/data_wipe/data/services/data_wipe_hooks.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:expense_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';

import '../../../../support/local_data_seed.dart';

class MockRemote extends Mock implements DataWipeRemoteDatasource {}

class _RecordingLocal extends DataWipeLocalDatasourceImpl {
  final DataWipeHarness harness;

  _RecordingLocal(this.harness, {required super.db, required super.registry});

  @override
  Future<void> wipeLocalData() async {
    harness.calls.add('wipe');
    if (harness.wipeFails) {
      throw const CacheException(message: 'disk full');
    }
    await super.wipeLocalData();
  }
}

class _RecordingSettings extends SettingsLocalDatasourceImpl {
  final List<String> calls;

  _RecordingSettings(this.calls, {required super.sharedPreferences});

  @override
  Future<UserSettings> resetSettings() {
    calls.add('resetSettings');

    return super.resetSettings();
  }
}

/// A repository over an in-memory database with seeded data, real settings
/// in mock prefs, a mocked server and hooks that record their calls.
class DataWipeHarness {
  final AppDatabase db = AppDatabase.forTesting(NativeDatabase.memory());
  final MockRemote remote = MockRemote();
  final List<String> calls = [];
  late final SharedPreferences prefs;
  late final DataWipeRepositoryImpl repository;
  bool signedIn = false;
  bool wipeFails = false;

  /// Thrown by the cancel hook when set.
  Object? cancelError;

  /// Thrown by the reset-sync-state hook when set.
  Object? resetSyncError;

  Future<void> setUp() async {
    SharedPreferences.setMockInitialValues({
      'user_settings':
          '{"currencyCode":"USD","emailFetchLimit":100,'
          '"notificationsEnabled":false,"theme":"dark",'
          '"createdAt":"2026-01-01T00:00:00.000Z",'
          '"updatedAt":"2026-01-01T00:00:00.000Z"}',
      'budget_names_repaired_u1': true,
    });
    prefs = await SharedPreferences.getInstance();
    await seedLocalData(db, records: 2, budgets: 1, categories: 3);
    repository = DataWipeRepositoryImpl(
      localDatasource: _RecordingLocal(
        this,
        db: db,
        registry: createDefaultSyncRegistry(),
      ),
      remoteDatasource: remote,
      settingsRepository: SettingsRepositoryImpl(
        localDatasource: _RecordingSettings(calls, sharedPreferences: prefs),
      ),
      hooks: DataWipeHooks(
        pauseSync: () async => calls.add('pauseSync'),
        resumeSync: () async => calls.add('resumeSync'),
        resetSyncState: () async {
          calls.add('resetSyncState');
          final error = resetSyncError;
          if (error != null) throw error;
        },
        cancelScheduledWork: () async {
          calls.add('cancelScheduledWork');
          final error = cancelError;
          if (error != null) throw error;
        },
        clearLocalPrefs: () async {
          calls.add('clearLocalPrefs');
          await prefs.remove('budget_names_repaired_u1');
        },
        isSignedIn: () async => signedIn,
      ),
    );
  }

  Future<int> recordCount() async => (await db.select(db.records).get()).length;

  Future<int> categoryCount() async =>
      (await db.select(db.categories).get()).length;

  Future<int> userCount() async => (await db.select(db.users).get()).length;

  /// Makes clearing the server succeed and records it.
  void serverClears() {
    when(() => remote.clearSyncedData()).thenAnswer((_) async {
      calls.add('clearServer');
    });
  }

  void serverFails(Exception error) {
    when(() => remote.clearSyncedData()).thenThrow(error);
  }
}
