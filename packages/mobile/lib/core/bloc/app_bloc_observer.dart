import 'package:flutter_bloc/flutter_bloc.dart';

import '../logger/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    appLogger.error('${bloc.runtimeType} error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
