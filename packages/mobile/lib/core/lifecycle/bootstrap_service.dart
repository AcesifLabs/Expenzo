import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../di/injection_container.dart' as di;

/// Owns the app's lifecycle operations that cross the bootstrap / DI
/// boundary:
/// - [restart] — cold-restart on Android (process exits, user reopens)
///   or full get_it reset + re-mount on iOS / other.
/// - [hardReset] — wipe get_it and re-register both the critical *and*
///   feature dependencies. Used by the long-press "hard reset" on the
///   error fallback.
///
/// The actual re-mount of the root widget is supplied by the caller via
/// [remountRoot] (typically `() => runApp(const ExpenzoApp())`), so
/// this service has no compile-time dependency on the root widget
/// type.
class BootstrapService {
  const BootstrapService({required this.remountRoot});

  /// Invoked on iOS / other after `get_it` is reset. On Android, the
  /// process is exited via `SystemNavigator.pop()` and this is never
  /// called.
  final Future<void> Function() remountRoot;

  /// Closes or restarts the app.
  /// - Android: exits the process via SystemNavigator.pop(). The user
  ///   must manually reopen the app.
  /// - iOS / other: resets all get_it singletons and re-mounts the root
  ///   widget, effectively restarting the app in-process.
  void restart() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      SystemNavigator.pop();
      return;
    }
    // iOS / other: reset every get_it singleton and re-mount the root.
    // `catchError` is a safety net: the user must always be able to
    // recover, even if reset() or remountRoot() throws.
    unawaited(
      GetIt.I
          .reset()
          .then((_) => remountRoot())
          .catchError((Object _) => remountRoot()),
    );
  }

  /// Wipe all get_it singletons and re-register both the critical
  /// *and* feature dependencies. The current `_startInitialization`
  /// registers both via `di.initCriticalDependencies()` and
  /// `di.initFeatureDependencies()` — the hard reset must reproduce
  /// both, otherwise feature-scoped blocs (Settings, etc.) stay
  /// unregistered on the second init.
  ///
  /// Errors from `reset()` are intentionally swallowed
  /// (`catchError((_) {})`): the user must always be able to
  /// recover, even if get_it is in an unknown state. The
  /// `initCriticalDependencies()` failure is surfaced to the
  /// caller via the returned `Future`.
  Future<void> hardReset() async {
    await GetIt.I.reset().catchError((Object _) {});
    await di.initCriticalDependencies();
    di.initFeatureDependencies();
  }
}
