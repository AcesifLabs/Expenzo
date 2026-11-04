import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/send_recurring_reminders.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_weekly_summary.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/sms_parser/application/realtime_sms_processor.dart';
import 'package:expense_tracker/features/sms_parser/data/mappers/incoming_sms_event_mapper.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';
import 'background_task_names.dart';
import 'background_task_scheduler.dart';

class BackgroundTaskDeps {
  final GetSettings getSettings;
  final GetWeeklySummary getWeeklySummary;
  final SendRecurringReminders sendRecurringReminders;
  final NotificationService notificationService;
  final RealtimeSmsProcessor smsProcessor;

  const BackgroundTaskDeps({
    required this.getSettings,
    required this.getWeeklySummary,
    required this.sendRecurringReminders,
    required this.notificationService,
    required this.smsProcessor,
  });
}

class BackgroundTaskRunner {
  final BackgroundTaskDeps deps;
  final BackgroundTaskScheduler scheduler;
  final DateTime Function() clock;

  BackgroundTaskRunner({
    required this.deps,
    required this.scheduler,
    this.clock = DateTime.now,
  });

  Future<bool> run(String taskName, {Map<String, dynamic>? input}) async {
    try {
      switch (taskName) {
        case BackgroundTaskNames.weeklySummary:
          await _runWeeklySummary();
        case BackgroundTaskNames.recurringReminders:
          await _runRecurringReminders();
        case BackgroundTaskNames.smsImport:
          await _runSmsImport(input);
        default:
          return false;
      }

      return true;
    } catch (e, s) {
      appLogger.error('Background task $taskName failed', e, s);

      return false;
    }
  }

  Future<void> _runWeeklySummary() async {
    final settings = await _loadSettings();
    if (settings.isEnabled(NotificationToggle.weeklySummary)) {
      final firstWeekday = settings
          .effectiveFirstDayOfWeek(LocaleSettings.currentLocale.languageCode)
          .weekday;
      final summary = await deps.getWeeklySummary(
        now: lastWeeklySummaryAt(clock(), firstWeekday: firstWeekday),
        firstWeekday: firstWeekday,
      );
      await summary.fold(
        (failure) => throw StateError(failure.message),
        deps.notificationService.showWeeklySummary,
      );
    }
    await scheduler.rearm(BackgroundTaskNames.weeklySummary, settings);
  }

  Future<void> _runRecurringReminders() async {
    final settings = await _loadSettings();
    await deps.sendRecurringReminders(now: clock());
    await scheduler.rearm(BackgroundTaskNames.recurringReminders, settings);
  }

  /// A failed parse is not retried here: the message stays in the native
  /// pending queue and is drained on the next app open.
  Future<void> _runSmsImport(Map<String, dynamic>? input) async {
    if (input == null || input.isEmpty) return;
    await deps.smsProcessor.importInBackground(
      mapIncomingSmsEventPayload(input),
    );
  }

  Future<UserSettings> _loadSettings() async {
    final result = await deps.getSettings(NoParams());

    return result.fold(
      (failure) => throw StateError(failure.message),
      (settings) => settings,
    );
  }
}
