import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/sync/handlers/parsing_rules_sync_handler.dart';
import 'package:expense_tracker/core/sync/sync_table_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sync_engine_harness.dart';

void main() {
  late SyncEngineHarness harness;

  setUp(() async {
    harness = SyncEngineHarness()..setUp();
    await harness.db.customStatement(
      "INSERT INTO parsing_rules (id, name, trigger_words, amount_pattern, "
      "source_type, date_order) VALUES ('rule-1', 'Old name', '[]', 'x', "
      "'sms', 'mdy')",
    );
  });

  tearDown(() => harness.tearDown());

  test('the server has no Date Order, so a pull keeps the local one', () async {
    harness.pullWith(
      () async => Response(
        requestOptions: RequestOptions(path: ApiConstants.syncPull),
        data: {
          'serverTime': '2026-10-20T00:00:00.000Z',
          'changes': [
            {
              'table': 'parsing_rules',
              'action': 'insert',
              'id': 'rule-1',
              'updatedAt': '2026-10-19T00:00:00.000Z',
              'data': {
                'name': 'New name',
                'triggerWords': '[]',
                'amountPattern': 'x',
                'sourceType': 'sms',
              },
            },
          ],
        },
      ),
    );

    await harness
        .engine(
          registry: SyncTableRegistry()..register(ParsingRulesSyncHandler()),
        )
        .syncNow();

    final row = await harness.db
        .customSelect(
          "SELECT name, date_order FROM parsing_rules WHERE id = 'rule-1'",
        )
        .getSingle();
    expect(row.data, {'name': 'New name', 'date_order': 'mdy'});
  });

  test('the push leaves Date Order out: the server would refuse it', () {
    final payload = ParsingRulesSyncHandler().toSyncPayload(
      harness.db.parsingRules.map({
        'id': 'r',
        'name': 'n',
        'trigger_words': '[]',
        'amount_pattern': 'x',
        'source_type': 'sms',
        'is_enabled': 1,
        'priority': 0,
        'date_order': 'mdy',
        'created_at': 0,
        'updated_at': 0,
      }),
    );

    expect(payload.containsKey('dateOrder'), isFalse);
  });
}
