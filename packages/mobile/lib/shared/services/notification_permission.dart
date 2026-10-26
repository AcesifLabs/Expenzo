import 'package:permission_handler/permission_handler.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

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
    appLogger.error('Notification permission request failed', e, s);
  }
}

Future<bool> requestNotificationPermission() async =>
    (await Permission.notification.request()).isGranted;

Future<bool> notificationPermissionGranted() =>
    Permission.notification.isGranted;
