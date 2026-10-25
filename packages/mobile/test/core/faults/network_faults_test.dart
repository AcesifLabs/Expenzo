import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/sync/sync_run_result.dart';
import 'package:expense_tracker/features/family/data/datasources/family_local_datasource.dart';
import 'package:expense_tracker/features/family/data/datasources/family_remote_datasource.dart';
import 'package:expense_tracker/features/family/data/repositories/family_repository_impl.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/factories/family_factory.dart';
import '../../support/fault_dio.dart';
import '../sync/sync_engine_harness.dart';

/// What each server or network fault shows, never a crash or a blank.
void main() {
  final errors = t.common.errors;

  group('Family summary', () {
    final now = DateTime.utc(2026, 10, 15, 12);
    late FamilyLocalDatasource local;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      local = FamilyLocalDatasource(
        prefs: await SharedPreferences.getInstance(),
        currentUserId: () => 'uid-a',
      );
    });

    FamilyRepositoryImpl repositoryFacing(NetworkFault fault) {
      final apiClient = FaultApiClient();
      when(() => apiClient.dio).thenReturn(faultyDio(fault));

      return FamilyRepositoryImpl(
        remote: FamilyRemoteDatasourceImpl(apiClient: apiClient),
        local: local,
        clock: () => now,
      );
    }

    const shownWithoutCache = {
      NetworkFault.serverError: 'server',
      NetworkFault.emptyBody: 'server',
      NetworkFault.html: 'network',
      NetworkFault.timeout: 'network',
      NetworkFault.unauthorized: 'auth',
    };

    for (final MapEntry(key: fault, value: kind) in shownWithoutCache.entries) {
      test('${fault.name} with nothing cached says what went wrong', () async {
        final result = await repositoryFacing(fault).getSummary('group-1');

        final failure = result.fold(
          (f) => f,
          (_) => fail('expected a failure'),
        );
        final expected = switch (kind) {
          'server' => errors.server,
          'network' => errors.network,
          _ => errors.auth,
        };
        expect(failureText(failure), expected);
      });
    }

    for (final fault in [
      NetworkFault.serverError,
      NetworkFault.html,
      NetworkFault.timeout,
    ]) {
      test('${fault.name} shows the last summary, marked as cached', () async {
        await local.writeGroup(makeMyGroup(), now);
        await local.writeSummary(makeGroupSummary(), now);

        final result = await repositoryFacing(fault).getSummary('group-1');

        expect(result.isRight(), isTrue);
        expect(result.getOrElse(() => fail('left')).fromCache, isTrue);
      });
    }
  });

  group('Sync', () {
    late SyncEngineHarness harness;

    setUp(() async {
      harness = SyncEngineHarness()..setUp();
      await harness.queue.enqueue(
        tableName: 'records',
        recordId: 'r1',
        action: 'update',
        payload: '{}',
      );
    });

    tearDown(() => harness.tearDown());

    for (final fault in NetworkFault.values) {
      test('${fault.name} ends in an error the user can retry, and keeps '
          'the change queued', () async {
        when(() => harness.apiClient.dio).thenReturn(faultyDio(fault));
        final cursorBefore = await TokenStorage.getLastSyncAt();

        final result = await harness.engine().syncNow();

        expect(result, SyncRunResult.failed);
        final queued = await harness.queue.getUnsynced();
        expect(queued.single.recordId, 'r1');
        expect(queued.single.attemptCount, 0, reason: 'not a rejection');
        expect(await TokenStorage.getLastSyncAt(), cursorBefore);
      });
    }
  });
}
