import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/sync/sync_switch_watcher.dart';

void main() {
  late List<bool> applied;
  late SyncSwitchWatcher watcher;

  setUp(() {
    applied = [];
    watcher = SyncSwitchWatcher(({required enabled}) async {
      applied.add(enabled);
    });
  });

  test('the first value only sets the baseline', () {
    watcher.update(enabled: false);

    expect(applied, isEmpty);
  });

  test('an unchanged value does nothing', () {
    watcher
      ..update(enabled: true)
      ..update(enabled: true);

    expect(applied, isEmpty);
  });

  test('each change is applied', () {
    watcher
      ..update(enabled: true)
      ..update(enabled: false)
      ..update(enabled: true);

    expect(applied, [false, true]);
  });
}
