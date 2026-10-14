import 'dart:async';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_state.dart';

/// The settings from the first [SettingsLoaded] on [states], or null when a
/// [SettingsError] comes first, [timeout] passes or the stream closes.
///
/// The start-up splash waits on this, so it must never hang.
Future<UserSettings?> firstSettings(
  Stream<SettingsState> states, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final completer = Completer<UserSettings?>();
  void complete(UserSettings? settings) {
    if (!completer.isCompleted) completer.complete(settings);
  }

  final subscription = states.listen((state) {
    if (state is SettingsLoaded) complete(state.settings);
    if (state is SettingsError) complete(null);
  }, onDone: () => complete(null));
  final timer = Timer(timeout, () => complete(null));
  final settings = await completer.future;
  timer.cancel();
  await subscription.cancel();

  return settings;
}
