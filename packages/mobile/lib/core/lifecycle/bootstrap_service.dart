import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../database/app_database.dart';
import '../database/database_seeder.dart';
import '../di/injection_container.dart' as di;

class BootstrapService {
  final Future<void> Function() remountRoot;

  BootstrapService({required this.remountRoot});

  Future<void> seedInitialData() async {
    try {
      final db = di.getIt<AppDatabase>();
      await DatabaseSeeder.seedInitialCategories(db);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('DatabaseSeeder failed (non-fatal): $e');
    }
  }

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
    await GetIt.I.reset().catchError((Object _) => null);
    await di.initCriticalDependencies();
    di.initFeatureDependencies();
  }
}
