import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncStatus', () {
    test('name returns the enum value name string', () {
      expect(SyncStatus.success.name, 'success');
      expect(SyncStatus.conflict.name, 'conflict');
      expect(SyncStatus.error.name, 'error');
    });

    test('fromString parses valid status strings', () {
      expect(SyncStatus.fromString('success'), SyncStatus.success);
      expect(SyncStatus.fromString('conflict'), SyncStatus.conflict);
      expect(SyncStatus.fromString('error'), SyncStatus.error);
    });

    test('fromString returns error for unknown strings', () {
      expect(SyncStatus.fromString('unknown'), SyncStatus.error);
      expect(SyncStatus.fromString(''), SyncStatus.error);
    });
  });
}
