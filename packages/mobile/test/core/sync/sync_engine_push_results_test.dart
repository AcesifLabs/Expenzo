import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'sync_engine_harness.dart';

void main() {
  late SyncEngineHarness harness;

  setUp(() => harness = SyncEngineHarness()..setUp());

  tearDown(() => harness.tearDown());

  void pushAnswers(List<Map<String, dynamic>> results) =>
      when(
        () => harness.dio.post<Object?>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.syncPush),
          data: {'results': results},
        ),
      );

  test('a rejected change counts an attempt and stays queued', () async {
    await harness.queueChange('r1');
    pushAnswers([
      {'id': 'r1', 'status': 'error', 'message': 'bad row'},
    ]);

    await harness.engine().syncNow();

    final item = (await harness.queue.getUnsynced()).single;
    expect(item.attemptCount, 1);
    expect(item.failedAt, isNull);
  });

  test(
    'every queued change of a record is marked sent, not only the last',
    () async {
      await harness.queueChange('r1');
      await harness.queueChange('r1');
      await harness.queueChange('r2');

      await harness.engine().syncNow();

      expect(await harness.queue.getUnsynced(), isEmpty);
    },
  );

  test('results matched by position: one record, two outcomes', () async {
    await harness.queueChange('r1');
    await harness.queueChange('r1');
    pushAnswers([
      {'id': 'r1', 'status': 'success'},
      {'id': 'r1', 'status': 'error', 'message': 'bad row'},
    ]);

    await harness.engine().syncNow();

    final left = await harness.queue.getUnsynced();
    expect(left, hasLength(1));
    expect(left.single.attemptCount, 1);
  });
}
