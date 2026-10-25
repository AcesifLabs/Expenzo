import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/sync/handlers/records_sync_handler.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'sync_engine_harness.dart';

void main() {
  late SyncEngineHarness harness;

  setUp(() async {
    harness = SyncEngineHarness()..setUp();
    await harness.db
        .into(harness.db.records)
        .insert(
          RecordsCompanion.insert(
            id: 'r1',
            amount: -50,
            description: 'Lunch, edited on this phone',
            date: DateTime(2026, 10, 1),
            recordType: 'OUT',
          ),
        );
    await harness.queue.enqueue(
      tableName: 'records',
      recordId: 'r1',
      action: 'update',
      payload: '{}',
    );
    harness.pullWith(
      () async => Response(
        requestOptions: RequestOptions(path: ApiConstants.syncPull),
        data: {
          'serverTime': '2026-10-20T00:00:00.000Z',
          'changes': [
            {
              'table': 'records',
              'action': 'insert',
              'id': 'r1',
              'updatedAt': '2026-10-02T00:00:00.000Z',
              'data': {
                'amount': -40,
                'description': 'Lunch, older server copy',
                'date': '2026-10-01T00:00:00.000Z',
                'recordType': 'OUT',
              },
            },
          ],
        },
      ),
    );
  });

  tearDown(() => harness.tearDown());

  SyncTableRegistry records() =>
      SyncTableRegistry()..register(RecordsSyncHandler());

  void pushAnswers(String status) =>
      when(
        () => harness.dio.post<Object?>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.syncPush),
          data: {
            'results': [
              {'id': 'r1', 'status': status},
            ],
          },
        ),
      );

  Future<Record> stored() => (harness.db.select(
    harness.db.records,
  )..where((r) => r.id.equals('r1'))).getSingle();

  test(
    'a pull does not overwrite an edit that is still waiting to be sent',
    () async {
      pushAnswers('success');

      await harness.engine(registry: records()).syncNow();

      final row = await stored();
      expect(row.amount, -50);
      expect(row.description, 'Lunch, edited on this phone');
    },
  );

  test(
    'when the server rejects the edit as older, its copy is applied',
    () async {
      pushAnswers('conflict');

      await harness.engine(registry: records()).syncNow();

      final row = await stored();
      expect(row.amount, -40);
      expect(row.description, 'Lunch, older server copy');
    },
  );

  test(
    'the server copy is still applied after the row stops being pulled',
    () async {
      final pulled = await harness.dio.get<Object?>(ApiConstants.syncPull);
      var pulls = 0;
      harness.pullWith(() async {
        pulls++;

        return pulls <= 5
            ? pulled
            : Response(
                requestOptions: RequestOptions(path: ApiConstants.syncPull),
                data: {
                  'serverTime': '2026-10-21T00:00:00.000Z',
                  'changes': <Object>[],
                },
              );
      });
      // Offline pushes: no answer, so no rejection is counted.
      when(
        () => harness.dio.post<Object?>(any(), data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.syncPush),
          type: DioExceptionType.connectionError,
        ),
      );
      final engine = harness.engine(registry: records());
      for (var i = 0; i < 6; i++) {
        await engine.syncNow();
      }
      expect((await stored()).amount, -50);

      pushAnswers('conflict');
      await engine.syncNow();

      expect((await stored()).amount, -40);
    },
  );

  test('rows without a waiting edit are applied as before', () async {
    pushAnswers('success');
    await harness.queue.markSynced([
      for (final item in await harness.queue.getUnsynced()) item.id,
    ]);

    await harness.engine(registry: records()).syncNow();

    expect((await stored()).amount, -40);
  });
}
