import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'background_task_names.dart';
import 'background_work.dart';

class BackgroundTaskScheduler {
  final BackgroundWork work;
  final DateTime Function() clock;

  final Duration? fixedDelay;

  final String Function() appLanguageCode;

  ({bool weekly, bool recurring, int firstWeekday})? _applied;

  BackgroundTaskScheduler({
    required this.work,
    this.clock = DateTime.now,
    this.fixedDelay,
    this.appLanguageCode = _currentLanguageCode,
  });

  Future<void> apply(UserSettings settings, {bool force = false}) async {
    if (!await work.ready) return;
    final wanted = (
      weekly: settings.isEnabled(NotificationToggle.weeklySummary),
      recurring: settings.isEnabled(NotificationToggle.recurringReminders),
      firstWeekday: _firstWeekday(settings),
    );
    if (!force && wanted == _applied) return;
    _applied = wanted;

    await _applyWeekly(on: wanted.weekly, firstWeekday: wanted.firstWeekday);
    await _applyRecurring(on: wanted.recurring);
  }

  Future<void> rearm(String taskName, UserSettings settings) async {
    if (!await work.ready) return;
    switch (taskName) {
      case BackgroundTaskNames.weeklySummary:
        await _applyWeekly(
          on: settings.isEnabled(NotificationToggle.weeklySummary),
          firstWeekday: _firstWeekday(settings),
        );
      case BackgroundTaskNames.recurringReminders:
        await _applyRecurring(
          on: settings.isEnabled(NotificationToggle.recurringReminders),
        );
    }
  }

  Future<void> cancelAll() async {
    if (!await work.ready) return;
    _applied = null;
    await work.cancel(BackgroundTaskNames.weeklySummary);
    await work.cancel(BackgroundTaskNames.recurringReminders);
  }

  int _firstWeekday(UserSettings settings) =>
      settings.effectiveFirstDayOfWeek(appLanguageCode()).weekday;

  Future<void> _applyWeekly({required bool on, required int firstWeekday}) {
    if (!on) return work.cancel(BackgroundTaskNames.weeklySummary);
    final now = clock();

    return work.scheduleOnce(
      BackgroundTaskNames.weeklySummary,
      _delayUntil(nextWeeklySummaryAt(now, firstWeekday: firstWeekday), now),
    );
  }

  Future<void> _applyRecurring({required bool on}) {
    if (!on) return work.cancel(BackgroundTaskNames.recurringReminders);
    final now = clock();

    return work.scheduleOnce(
      BackgroundTaskNames.recurringReminders,
      _delayUntil(nextDailyAt(now, AppConstants.recurringReminderHour), now),
    );
  }

  Duration _delayUntil(DateTime at, DateTime now) =>
      fixedDelay ?? at.difference(now);

  static String _currentLanguageCode() =>
      LocaleSettings.currentLocale.languageCode;
}
