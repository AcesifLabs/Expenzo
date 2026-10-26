import 'dart:async';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_state.dart';

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
