import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// The queries the app runs most, as the DAOs build them. A full scan of
/// these tables means a missing or unusable index: it gets slower with
/// every record the user adds.
const _hotQueries = {
  'records page (Activity)':
      'SELECT * FROM records WHERE date BETWEEN 0 AND 9 ORDER BY date DESC '
      'LIMIT 30',
  'spending in a date range':
      "SELECT SUM(ABS(amount)) FROM records WHERE date BETWEEN 0 AND 9 "
      "AND record_type = 'OUT'",
  'spending in a category':
      "SELECT SUM(ABS(amount)) FROM records WHERE category_id = 'c' "
      "AND date BETWEEN 0 AND 9 AND record_type = 'OUT'",
  'spending per budget':
      "SELECT budget_id, SUM(ABS(amount)) FROM records "
      "WHERE budget_id IN ('a', 'b') AND record_type = 'OUT' "
      'GROUP BY budget_id',
  'already-imported SMS lookup':
      "SELECT source_id FROM records WHERE source_id IN ('s1', 's2')",
  'already-imported SMS amounts, with renamed copies':
      "SELECT source_id, amount FROM records WHERE source_id IN ('s1', 's2') "
      "OR (source_id >= 's1#' AND source_id < 's1\$') "
      "OR (source_id >= 's2#' AND source_id < 's2\$')",
  'search':
      'SELECT r.* FROM records r JOIN expense_fts ON expense_fts.rowid = '
      "r.rowid WHERE expense_fts MATCH 'lunch' ORDER BY r.date DESC",
  'pending sync changes':
      'SELECT * FROM sync_queue WHERE synced_at IS NULL AND failed_at IS NULL '
      'ORDER BY created_at',
  'Failed Sync Change count':
      'SELECT COUNT(*) FROM sync_queue WHERE synced_at IS NULL '
      'AND failed_at IS NOT NULL',
  'pending sync count':
      'SELECT COUNT(*) FROM sync_queue WHERE synced_at IS NULL '
      'AND failed_at IS NULL',
};

/// Any `SCAN` of these tables reads every row (or every index entry). The
/// exceptions are the partial queue indexes: they hold only the changes
/// still to push, or the failed ones.
bool _isFullScan(String detail) =>
    RegExp(r'^SCAN (records|sync_queue)\b').hasMatch(detail) &&
    !detail.contains('idx_sync_queue_pending') &&
    !detail.contains('idx_sync_queue_failed');

void main() {
  late AppDatabase db;

  setUpAll(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // No ANALYZE: phones never run it, so the planner has no statistics.
    for (var i = 0; i < 500; i++) {
      await db.customStatement(
        'INSERT INTO records (id, amount, description, date, record_type, '
        'category_id, budget_id, source, source_id) '
        "VALUES ('r$i', -$i, 'lunch $i', $i, 'OUT', 'c${i % 9}', "
        "'b${i % 7}', 'sms', 's$i')",
      );
    }
  });

  tearDownAll(() => db.close());

  _hotQueries.forEach((name, sql) {
    test('$name uses an index', () async {
      final plan = [
        for (final row
            in await db.customSelect('EXPLAIN QUERY PLAN $sql').get())
          row.read<String>('detail'),
      ];

      expect(plan.where(_isFullScan), isEmpty, reason: plan.join('\n'));
    });
  });

  test('retrying Failed Sync Changes finds newer changes by index', () async {
    final plan = [
      for (final row
          in await db
              .customSelect(
                'EXPLAIN QUERY PLAN SELECT 1 FROM sync_queue AS failed '
                'WHERE failed.failed_at IS NOT NULL AND failed.synced_at IS NULL '
                'AND EXISTS (SELECT 1 FROM sync_queue AS newer '
                'WHERE newer.entity_table = failed.entity_table '
                'AND newer.record_id = failed.record_id AND newer.id > failed.id)',
              )
              .get())
        row.read<String>('detail'),
    ];

    expect(plan.join('\n'), contains('idx_sync_queue_record'));
  });
}
