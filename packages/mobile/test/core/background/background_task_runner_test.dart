import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/background/background_task_names.dart';
import 'package:expense_tracker/core/background/background_task_runner.dart';
import 'package:expense_tracker/core/background/background_task_scheduler.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/send_recurring_reminders.dart';
import 'package:expense_tracker/features/reports/domain/entities/weekly_summary.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_weekly_summary.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

import '../../support/factories/user_settings_factory.dart';

class _MockGetSettings extends Mock implements GetSettings {}

class _MockGetWeeklySummary extends Mock implements GetWeeklySummary {}

class _MockSendRecurringReminders extends Mock
    implements SendRecurringReminders {}

class _MockNotificationService extends Mock implements NotificationService {}

class _MockScheduler extends Mock implements BackgroundTaskScheduler {}

void main() {
  final now = DateTime(2026, 10, 18, 20);
  final summary = WeeklySummary(
    thisWeekTotal: 100,
    lastWeekTotal: 50,
    weekStart: DateTime(2026, 10, 12),
  );

  late _MockGetSettings getSettings;
  late _MockGetWeeklySummary getWeeklySummary;
  late _MockSendRecurringReminders sendReminders;
  late _MockNotificationService notifications;
  late _MockScheduler scheduler;
  late BackgroundTaskRunner runner;

  setUpAll(() {
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
    registerFallbackValue(NoParams());
    registerFallbackValue(makeUserSettings());
    registerFallbackValue(summary);
  });

  setUp(() {
    getSettings = _MockGetSettings();
    getWeeklySummary = _MockGetWeeklySummary();
    sendReminders = _MockSendRecurringReminders();
    notifications = _MockNotificationService();
    scheduler = _MockScheduler();
    runner = BackgroundTaskRunner(
      deps: BackgroundTaskDeps(
        getSettings: getSettings,
        getWeeklySummary: getWeeklySummary,
        sendRecurringReminders: sendReminders,
        notificationService: notifications,
      ),
      scheduler: scheduler,
      clock: () => now,
    );
    when(() => scheduler.rearm(any(), any())).thenAnswer((_) async {});
    when(
      () => getWeeklySummary(now: any(named: 'now')),
    ).thenAnswer((_) async => Right(summary));
    when(() => notifications.showWeeklySummary(any())).thenAnswer((_) async {});
    when(
      () => sendReminders(now: any(named: 'now')),
    ).thenAnswer((_) async => const Right(1));
  });

  void settings(UserSettings value) {
    when(() => getSettings(any())).thenAnswer((_) async => Right(value));
  }

  test('weekly task shows the summary and re-arms', () async {
    final value = makeUserSettings(weeklySummaryEnabled: true);
    settings(value);

    expect(await runner.run(BackgroundTaskNames.weeklySummary), isTrue);

    verify(() => getWeeklySummary(now: DateTime(2026, 10, 18, 20))).called(1);
    verify(() => notifications.showWeeklySummary(summary)).called(1);
    verify(
      () => scheduler.rearm(BackgroundTaskNames.weeklySummary, value),
    ).called(1);
  });

  test(
    'weekly task with the toggle off shows nothing and returns true',
    () async {
      final value = makeUserSettings();
      settings(value);

      expect(await runner.run(BackgroundTaskNames.weeklySummary), isTrue);

      verifyNever(() => notifications.showWeeklySummary(any()));
      verify(
        () => scheduler.rearm(BackgroundTaskNames.weeklySummary, value),
      ).called(1);
    },
  );

  test('recurring task sends reminders with the clock and re-arms', () async {
    final value = makeUserSettings();
    settings(value);

    expect(await runner.run(BackgroundTaskNames.recurringReminders), isTrue);

    verify(() => sendReminders(now: now)).called(1);
    verify(
      () => scheduler.rearm(BackgroundTaskNames.recurringReminders, value),
    ).called(1);
  });

  test(
    'a summary that runs after midnight reports the week just ended',
    () async {
      settings(makeUserSettings(weeklySummaryEnabled: true));
      runner = BackgroundTaskRunner(
        deps: BackgroundTaskDeps(
          getSettings: getSettings,
          getWeeklySummary: getWeeklySummary,
          sendRecurringReminders: sendReminders,
          notificationService: notifications,
        ),
        scheduler: scheduler,
        clock: () => DateTime(2026, 10, 19, 1),
      );

      await runner.run(BackgroundTaskNames.weeklySummary);

      verify(() => getWeeklySummary(now: DateTime(2026, 10, 18, 20))).called(1);
    },
  );

  test('a failed summary returns false so Workmanager retries', () async {
    settings(makeUserSettings(weeklySummaryEnabled: true));
    when(
      () => getWeeklySummary(now: any(named: 'now')),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db')));

    expect(await runner.run(BackgroundTaskNames.weeklySummary), isFalse);
    verifyNever(() => notifications.showWeeklySummary(any()));
  });

  test('failed reminders still re-arm the next run', () async {
    final value = makeUserSettings();
    settings(value);
    when(
      () => sendReminders(now: any(named: 'now')),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db')));

    expect(await runner.run(BackgroundTaskNames.recurringReminders), isTrue);
    verify(
      () => scheduler.rearm(BackgroundTaskNames.recurringReminders, value),
    ).called(1);
  });

  test('an unknown task returns false', () async {
    expect(await runner.run('expenzo.unknown'), isFalse);
  });

  test('an exception returns false', () async {
    when(() => getSettings(any())).thenThrow(StateError('boom'));

    expect(await runner.run(BackgroundTaskNames.weeklySummary), isFalse);
  });
}
