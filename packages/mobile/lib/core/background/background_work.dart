import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// The plugin calls the scheduler needs, so tests don't touch platform
/// channels.
abstract class BackgroundWork {
  /// Completes once Workmanager is initialised; false if that failed.
  Future<bool> get ready;

  /// Registers one-off work [name] to run after [delay].
  Future<void> scheduleOnce(String name, Duration delay);

  Future<void> cancel(String name);
}

class WorkmanagerBackgroundWork implements BackgroundWork {
  static final Completer<bool> _initialized = Completer<bool>();

  /// True inside Workmanager's isolate, where a task re-arms itself.
  static bool _inBackground = false;

  @override
  Future<bool> get ready => _initialized.future;

  /// Call once before anything schedules. A failure never blocks start-up;
  /// it makes every later call a no-op.
  static Future<void> initialize(Function dispatcher) async {
    if (_initialized.isCompleted) return;
    try {
      await Workmanager().initialize(dispatcher);
      _initialized.complete(true);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('Workmanager init failed: $e');
      _initialized.complete(false);
    }
  }

  /// Inside Workmanager's isolate the plugin is already set up.
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
      // Replacing the work that is running would cancel it; from inside a
      // run, queue the next one after it instead (append-or-replace).
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
