import 'dart:async';
import 'dart:isolate';

/// Runs [computation] in a new isolate and kills that isolate when
/// [deadline] passes, throwing a [TimeoutException].
///
/// `Isolate.run(...).timeout(...)` only stops waiting: the isolate keeps
/// running. A user's regex that backtracks forever would then hold a CPU
/// core until the app is closed. Killing the isolate stops it.
Future<R> runWithDeadline<R>(
  R Function() computation,
  Duration deadline,
) async {
  final port = ReceivePort();
  final isolate = await Isolate.spawn(
    _runJob<R>,
    (computation, port.sendPort),
    onError: port.sendPort,
    onExit: port.sendPort,
    errorsAreFatal: true,
  );
  try {
    final message = await port.first.timeout(deadline);

    return switch (message) {
      (R result,) => result,
      // onError sends [error, stack] as strings.
      [final Object? error, final Object? stack] => throw RemoteError(
        '$error',
        '$stack',
      ),
      _ => throw StateError('Isolate exited without a result'),
    };
  } on TimeoutException {
    isolate.kill(priority: Isolate.immediate);
    rethrow;
  } finally {
    port.close();
  }
}

void _runJob<R>((R Function(), SendPort) job) {
  final (computation, port) = job;
  // A one-element record, so a null result is told apart from onExit's null.
  port.send((computation(),));
}
