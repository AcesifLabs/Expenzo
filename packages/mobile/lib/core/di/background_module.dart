import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/background/background_task_scheduler.dart';
import 'package:expense_tracker/core/background/background_task_runner.dart';
import 'package:expense_tracker/core/background/background_work.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/send_recurring_reminders.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_weekly_summary.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

/// `--dart-define=EXPENZO_BG_TEST_DELAY=true` runs background work after one
/// minute, for the manual device check. Never ship with it.
const Duration? _debugDelay = bool.fromEnvironment('EXPENZO_BG_TEST_DELAY')
    ? Duration(minutes: 1)
    : null;

void initBackgroundModule(GetIt getIt) {
  getIt.registerLazySingleton<BackgroundWork>(WorkmanagerBackgroundWork.new);
  getIt.registerLazySingleton(
    () => BackgroundTaskScheduler(
      work: getIt<BackgroundWork>(),
      fixedDelay: _debugDelay,
    ),
  );
  getIt.registerLazySingleton(
    () => BackgroundTaskRunner(
      deps: BackgroundTaskDeps(
        getSettings: getIt<GetSettings>(),
        getWeeklySummary: getIt<GetWeeklySummary>(),
        sendRecurringReminders: getIt<SendRecurringReminders>(),
        notificationService: getIt<NotificationService>(),
      ),
      scheduler: getIt<BackgroundTaskScheduler>(),
    ),
  );
}
