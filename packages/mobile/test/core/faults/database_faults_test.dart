import 'dart:io';

import 'package:drift/native.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/database_file.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/lifecycle/bootstrap_service.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_fallback.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../support/factories/record_factory.dart';
import '../../support/pump_localized.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('expenzo_faults'));
  tearDown(() => dir.deleteSync(recursive: true));

  File junkFile() =>
      File('${dir.path}/$databaseFileName')
        ..writeAsBytesSync(List.generate(8192, (i) => (i * 37) % 251));

  group('A database file that is not a database', () {
    test('fails to open with an error recognised as unreadable', () async {
      final db = AppDatabase.forTesting(NativeDatabase(junkFile()));
      addTearDown(db.close);

      final error = await db
          .customSelect('SELECT 1')
          .get()
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isNotNull);
      expect(isDatabaseFileError(error!), isTrue);
    });

    test('is recognised through the background isolate too', () async {
      final db = AppDatabase.forTesting(
        NativeDatabase.createInBackground(junkFile()),
      );
      addTearDown(db.close);

      final error = await db
          .customSelect('SELECT 1')
          .get()
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(isDatabaseFileError(error!), isTrue);
    });

    test('other database errors are not', () {
      expect(isDatabaseFileError(StateError('locked')), isFalse);
    });

    test('once set aside, the same path opens as a fresh database', () async {
      final file = junkFile();
      File('${file.path}-wal').writeAsStringSync('junk');

      await setDatabaseFileAside(file);

      expect(File('${file.path}.corrupt').existsSync(), isTrue);
      expect(File('${file.path}-wal').existsSync(), isFalse);
      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);
      expect(await db.select(db.records).get(), isEmpty);
    });

    test(
      'Reset local data sets the file aside and starts the app again',
      () async {
        final file = junkFile();
        FlutterSecureStorage.setMockInitialValues({
          'last_sync_at': '2026-10-01T00:00:00.000Z',
          'is_first_sync': 'false',
        });
        SharedPreferences.setMockInitialValues({});
        var remounts = 0;
        final bootstrap = BootstrapService(remountRoot: () async => remounts++);
        GetIt.I
          ..registerSingleton<BootstrapService>(bootstrap)
          ..registerSingleton<AppDatabase>(
            AppDatabase.forTesting(NativeDatabase(file)),
          );
        addTearDown(GetIt.I.reset);

        await bootstrap.resetLocalData(file: file);

        expect(File('${file.path}.corrupt').existsSync(), isTrue);
        expect(remounts, 1);
        expect(GetIt.I.isRegistered<AppDatabase>(), isFalse);
        expect(GetIt.I<BootstrapService>(), same(bootstrap));

        expect(await TokenStorage.getLastSyncAt(), isNull);
        expect(await TokenStorage.isFirstSync(), isTrue);
      },
    );
  });

  test('a full disk shows the storage message', () async {
    final db = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (raw) => raw.execute('PRAGMA max_page_count = 40'),
      ),
    );
    addTearDown(db.close);
    final records = RecordLocalDatasourceImpl(recordDao: RecordDao(db));

    Object? error;
    for (var i = 0; i < 5000 && error == null; i++) {
      try {
        await records.addRecord(
          makeRecord(id: 'r$i', description: 'Groceries ' * 20),
        );
      } catch (e) {
        error = e;
      }
    }

    expect(error, isA<CacheException>());
    expect(
      failureText((error! as CacheException).toFailure()),
      t.common.errors.storage,
    );
  });

  group('Start-up fallback for an unreadable database', () {
    testWidgets('offers Reset local data, asking before it deletes', (
      tester,
    ) async {
      var resets = 0;
      await pumpLocalized(
        tester,
        AppErrorFallback(
          onRestart: () {},
          onSendFeedback: () {},
          fallbackContext: AppFallbackContext.init,
          referenceId: 'ABC123',
          onRetry: () {},
          onResetLocalData: () => resets++,
        ),
      );
      final fallback = t.common.fallback;
      expect(find.text(fallback.storageBody), findsOneWidget);

      await tester.tap(find.text(fallback.resetLocalData));
      await tester.pump();
      expect(resets, 0);
      expect(find.text(fallback.resetConfirm), findsOneWidget);

      await tester.tap(find.text(fallback.resetConfirmAction));
      expect(resets, 1);
    });

    testWidgets('other start-up errors offer only Try again', (tester) async {
      await pumpLocalized(
        tester,
        AppErrorFallback(
          onRestart: () {},
          onSendFeedback: () {},
          fallbackContext: AppFallbackContext.init,
          referenceId: 'ABC123',
          onRetry: () {},
        ),
      );

      expect(find.text(t.common.fallback.resetLocalData), findsNothing);
      expect(find.text(t.common.tryAgain), findsOneWidget);
    });
  });
}
