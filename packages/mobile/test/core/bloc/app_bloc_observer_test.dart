import 'package:expense_tracker/core/bloc/app_bloc_observer.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker/talker.dart';

class _Cubit extends Cubit<int> {
  _Cubit() : super(0);

  void fail() => addError(StateError('reload failed'), StackTrace.current);
}

void main() {
  test('errors a bloc adds are logged', () async {
    final previous = Bloc.observer;
    Bloc.observer = const AppBlocObserver();
    addTearDown(() => Bloc.observer = previous);
    final before = appLogger.history.length;

    final cubit = _Cubit()..fail();
    await cubit.close();

    final logged = appLogger.history.skip(before).toList();
    expect(
      logged.any(
        (log) => log.logLevel == LogLevel.error && log.exception is StateError,
      ),
      isTrue,
    );
  });
}
