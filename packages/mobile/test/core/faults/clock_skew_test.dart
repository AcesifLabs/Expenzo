import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../sync/sync_engine_harness.dart';

/// The server keeps the newer of two edits by time, so a phone clock set
/// days wrong must not decide which edit wins.
void main() {
  late SyncEngineHarness harness;
  final serverNow = DateTime.utc(2026, 10, 15, 10);

  setUp(() {
    harness = SyncEngineHarness()..setUp();
    harness.pullWith(
      () async => Response(
        requestOptions: RequestOptions(path: ApiConstants.syncPull),
        data: {
          'serverTime': serverNow.toIso8601String(),
          'changes': <Object>[],
        },
      ),
    );
  });

  tearDown(() => harness.tearDown());

  Future<String> pushedTimeWithPhoneAt(DateTime phoneNow) async {
    final pushes = <Map<String, dynamic>>[];
    when(
      () => harness.dio.post<Object?>(any(), data: any(named: 'data')),
    ).thenAnswer((call) async {
      pushes.add(call.namedArguments[#data] as Map<String, dynamic>);

      return Response(
        requestOptions: RequestOptions(path: ApiConstants.syncPush),
        data: {
          'results': [
            {'id': 'r1', 'status': 'success'},
          ],
        },
      );
    });

    await withClock(Clock.fixed(phoneNow), () async {
      await harness.queue.enqueue(
        tableName: 'records',
        recordId: 'r1',
        action: 'update',
        payload: '{}',
      );
      await harness.engine().syncNow();
    });
    final changes = pushes.single['changes'] as List;

    return (changes.single as Map)['updatedAt'] as String;
  }

  test('a phone two days ahead stamps its edit with server time', () async {
    final pushed = await pushedTimeWithPhoneAt(
      serverNow.add(const Duration(days: 2)),
    );

    expect(DateTime.parse(pushed), serverNow);
  });

  test('a phone two days behind does too, so its edit is not lost', () async {
    final pushed = await pushedTimeWithPhoneAt(
      serverNow.subtract(const Duration(days: 2)),
    );

    expect(DateTime.parse(pushed), serverNow);
  });
}
