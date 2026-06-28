import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../di/injection_container.dart' as di;

class BootstrapService {
  const BootstrapService({required this.remountRoot});

  final Future<void> Function() remountRoot;

  void restart() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      SystemNavigator.pop();
      return;
    }

    unawaited(
      GetIt.I
          .reset()
          .then((_) => remountRoot())
          .catchError((Object _) => remountRoot()),
    );
  }

  Future<void> hardReset() async {
    await GetIt.I.reset().catchError((Object _) {});
    await di.initCriticalDependencies();
    di.initFeatureDependencies();
  }
}
