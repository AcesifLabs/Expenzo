import 'dart:async';

class SyncSwitchWatcher {
  final Future<void> Function({required bool enabled}) _apply;
  bool? _last;

  SyncSwitchWatcher(this._apply);

  void update({required bool enabled}) {
    final previous = _last;
    _last = enabled;
    if (previous == null || previous == enabled) return;
    unawaited(_apply(enabled: enabled));
  }
}
