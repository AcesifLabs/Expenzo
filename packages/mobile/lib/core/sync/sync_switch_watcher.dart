import 'dart:async';

/// Passes Sync switch changes to the engine. The first value only sets the
/// baseline: at start-up `AuthBloc` starts sync after its conflict check.
class SyncSwitchWatcher {
  final Future<void> Function({required bool enabled}) _apply;
  bool? _last;

  SyncSwitchWatcher(this._apply);

  /// Calls the engine only when [enabled] differs from the last value.
  void update({required bool enabled}) {
    final previous = _last;
    _last = enabled;
    if (previous == null || previous == enabled) return;
    unawaited(_apply(enabled: enabled));
  }
}
