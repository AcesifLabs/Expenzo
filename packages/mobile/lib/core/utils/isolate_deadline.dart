import 'dart:async';
import 'dart:isolate';

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

  port.send((computation(),));
}
