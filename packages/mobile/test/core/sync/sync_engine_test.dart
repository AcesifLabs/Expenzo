import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';

void main() {
  group('SyncEngine', () {
    group('SyncConflictType', () {
      test('has correct enum values', () {
        expect(SyncConflictType.values.length, 4);
        expect(SyncConflictType.none, isNotNull);
        expect(SyncConflictType.localOnly, isNotNull);
        expect(SyncConflictType.cloudOnly, isNotNull);
        expect(SyncConflictType.conflict, isNotNull);
      });
    });

    group('SyncMode', () {
      test('has correct enum values', () {
        expect(SyncMode.values.length, 3);
        expect(SyncMode.localWins, isNotNull);
        expect(SyncMode.cloudWins, isNotNull);
        expect(SyncMode.merge, isNotNull);
      });
    });

    group('chunkSize', () {
      test('is 500', () {
        expect(SyncEngine.chunkSize, 500);
      });
    });
  });
}
