import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/week_utils.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'background_task_names.dart';
import 'background_work.dart';

/// Registers or cancels the weekly summary and recurring reminder work to
/// match [UserSettings]. One-off tasks, re-armed after each run, keep the
/// clock time; periodic work drifts.
class BackgroundTaskScheduler {
  final BackgroundWork work;
  final DateTime Function() clock;

  /// Replaces every computed delay; for tests and the manual device check.
  final Duration? fixedDelay;

  /// The last applied (weekly, recurring) pair, so unrelated setting
  /// changes don't re-register work.
  ({bool weekly, bool recurring})? _applied;

  BackgroundTaskScheduler({
    required this.work,
    this.clock = DateTime.now,
    this.fixedDelay,
  });

  Future<void> apply(UserSettings settings, {bool force = false}) async {
    if (!await work.ready) return;
    final wanted = (
      weekly: settings.isEnabled(NotificationToggle.weeklySummary),
      recurring: settings.isEnabled(NotificationToggle.recurringReminders),
    );
    if (!force && wanted == _applied) return;
    _applied = wanted;

    await _applyWeekly(on: wanted.weekly);
    await _applyRecurring(on: wanted.recurring);
  }

  /// After [taskName] ran: schedules its next run, or cancels it if its
  /// toggle is now off. Leaves the other task alone; in the worker isolate
  /// scheduling appends, so touching a pending task would queue a copy.
  Future<void> rearm(String taskName, UserSettings settings) async {
    if (!await work.ready) return;
    switch (taskName) {
      case BackgroundTaskNames.weeklySummary:
        await _applyWeekly(
          on: settings.isEnabled(NotificationToggle.weeklySummary),
        );
      case BackgroundTaskNames.recurringReminders:
        await _applyRecurring(
          on: settings.isEnabled(NotificationToggle.recurringReminders),
        );
    }
  }

  /// Cancels both; the next [apply] registers again.
  Future<void> cancelAll() async {
    if (!await work.ready) return;
    _applied = null;
    await work.cancel(BackgroundTaskNames.weeklySummary);
    await work.cancel(BackgroundTaskNames.recurringReminders);
  }

  Future<void> _applyWeekly({required bool on}) {
    if (!on) return work.cancel(BackgroundTaskNames.weeklySummary);
    final now = clock();

    return work.scheduleOnce(
      BackgroundTaskNames.weeklySummary,
      _delayUntil(nextWeeklySummaryAt(now), now),
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
}
