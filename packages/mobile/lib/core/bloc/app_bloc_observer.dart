import 'package:flutter_bloc/flutter_bloc.dart';

import '../logger/app_logger.dart';

/// Logs errors blocs report with `addError`, which otherwise go nowhere.
/// Errors thrown out of event handlers already reach the zone handler.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    appLogger.error('${bloc.runtimeType} error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
