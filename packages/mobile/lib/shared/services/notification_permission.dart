import 'package:permission_handler/permission_handler.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

/// Budget alerts are on by default, but Android 13+ only shows notifications
/// once the user allows them. Ask at the moment alerts start to matter (the
/// first budget is created), and only if Android can still show the prompt.
Future<void> requestBudgetAlertPermissionIfNeeded() async {
  if (!di.getIt.isRegistered<SettingsBloc>()) return;
  final state = di.getIt<SettingsBloc>().state;
  if (state is! SettingsLoaded) return;
  final settings = state.settings;
  if (!settings.isEnabled(NotificationToggle.budgetOver) &&
      !settings.isEnabled(NotificationToggle.budgetNearLimit)) {
    return;
  }

  try {
    final status = await Permission.notification.status;
    if (status.isDenied) await Permission.notification.request();
  } catch (e, s) {
    // Best effort: a failed prompt must never break the screen that asked.
    appLogger.error('Notification permission request failed', e, s);
  }
}

/// Asks Android for permission to post notifications.
Future<bool> requestNotificationPermission() async =>
    (await Permission.notification.request()).isGranted;

Future<bool> notificationPermissionGranted() =>
    Permission.notification.isGranted;
