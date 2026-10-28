import 'dart:async';
import 'dart:isolate';

import 'package:expense_tracker/core/utils/isolate_deadline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns the result of quick work', () async {
    expect(await runWithDeadline(() => 6 * 7, const Duration(seconds: 5)), 42);
  });

  test('returns a null result', () async {
    expect(
      await runWithDeadline<int?>(() => null, const Duration(seconds: 5)),
      isNull,
    );
  });

  test('passes errors back as RemoteError', () {
    expect(
      runWithDeadline<int>(
        () => throw StateError('broken rule'),
        const Duration(seconds: 5),
      ),
      throwsA(isA<RemoteError>()),
    );
  });

  test('a regex that backtracks forever is stopped at the deadline', () async {
    final watch = Stopwatch()..start();

    await expectLater(
      runWithDeadline(
        () => RegExp(r'(a+)+$').hasMatch('${'a' * 40}b'),
        const Duration(milliseconds: 300),
      ),
      throwsA(isA<TimeoutException>()),
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });
}
