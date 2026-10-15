import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/lifecycle/local_data_epoch.dart';

void main() {
  test('starts at 0; bump increments and notifies listeners', () {
    final epoch = LocalDataEpoch();
    var notified = 0;
    epoch.addListener(() => notified++);

    expect(epoch.value, 0);
    epoch.bump();

    expect(epoch.value, 1);
    expect(notified, 1);
  });
}
