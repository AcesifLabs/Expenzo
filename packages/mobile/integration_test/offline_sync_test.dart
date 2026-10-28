import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/fault_injection_interceptor.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

import 'support/app.dart';
import 'support/fake_server.dart';

void main() {
  patrolTest('a record made offline syncs when back online', ($) async {
    await TokenStorage.saveToken('e2e-token');
    await TokenStorage.markFirstSyncDone();
    await launchOnboarded($);

    final dio = ApiClient().dio;
    final offline = FaultInjectionInterceptor(errorRate: 1, status: 0);
    final server = FakeSyncServer();
    dio.interceptors.insert(0, offline);
    addTearDown(() => dio.interceptors.remove(offline));

    final records = di.getIt<RecordRepository>();
    final added = await records.addRecord(
      Record(
        amount: -250,
        description: 'Lunch with no signal',
        date: DateTime.now(),
        recordType: RecordType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    expect(added.isRight(), isTrue);
    final queue = SyncQueueDao(di.getIt());
    expect(await queue.getUnsyncedCount(), greaterThan(0));

    final engine = di.getIt<SyncEngine>();
    expect(await engine.syncNow(), SyncRunResult.offline);
    expect(await queue.getUnsyncedCount(), greaterThan(0));

    dio.interceptors
      ..remove(offline)
      ..insert(0, server);
    addTearDown(() => dio.interceptors.remove(server));
    expect(await engine.syncNow(), SyncRunResult.success);

    expect(await queue.getUnsyncedCount(), 0);
    expect(
      server.pushed.any((c) => c['table'] == 'records'),
      isTrue,
      reason: 'the record reached the server',
    );
  });
}
