import 'dart:async';

import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:workmanager/workmanager.dart';

abstract class BackgroundWork {
  Future<bool> get ready;

  Future<void> scheduleOnce(String name, Duration delay);

  Future<void> cancel(String name);
}

class WorkmanagerBackgroundWork implements BackgroundWork {
  static final Completer<bool> _initialized = Completer<bool>();

  static bool _inBackground = false;

  @override
  Future<bool> get ready => _initialized.future;

  static Future<void> initialize(Function dispatcher) async {
    if (_initialized.isCompleted) return;
    try {
      await Workmanager().initialize(dispatcher);
      _initialized.complete(true);
    } catch (e, s) {
      appLogger.error('Workmanager init failed', e, s);
      _initialized.complete(false);
    }
  }

  static void markReadyInBackground() {
    _inBackground = true;
    if (!_initialized.isCompleted) _initialized.complete(true);
  }

  @override
  Future<void> scheduleOnce(String name, Duration delay) async {
    if (!await ready) return;
    await Workmanager().registerOneOffTask(
      name,
      name,
      initialDelay: delay,

      existingWorkPolicy: _inBackground
          ? ExistingWorkPolicy.update
          : ExistingWorkPolicy.replace,
    );
  }

  @override
  Future<void> cancel(String name) async {
    if (!await ready) return;
    await Workmanager().cancelByUniqueName(name);
  }
}
