import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/background/background_task_names.dart';
import 'package:expense_tracker/core/background/background_task_scheduler.dart';
import 'package:expense_tracker/core/background/background_work.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';

import '../../support/factories/user_settings_factory.dart';

class _FakeBackgroundWork implements BackgroundWork {
  bool isReady = true;
  final scheduled = <String, Duration>{};
  final cancelled = <String>[];

  int get calls => scheduled.length + cancelled.length;

  void reset() {
    scheduled.clear();
    cancelled.clear();
  }

  @override
  Future<bool> get ready async => isReady;

  @override
  Future<void> scheduleOnce(String name, Duration delay) async =>
      scheduled[name] = delay;

  @override
  Future<void> cancel(String name) async => cancelled.add(name);
}

void main() {
  const weekly = BackgroundTaskNames.weeklySummary;
  const recurring = BackgroundTaskNames.recurringReminders;

  final now = DateTime(2026, 10, 14, 8);

  late _FakeBackgroundWork work;
  late BackgroundTaskScheduler scheduler;

  setUp(() {
    work = _FakeBackgroundWork();
    scheduler = BackgroundTaskScheduler(
      work: work,
      clock: () => now,
      appLanguageCode: () => 'en',
    );
  });

  test('weekly on schedules once with the delay to the next summary', () async {
    await scheduler.apply(makeUserSettings(weeklySummaryEnabled: true));

    expect(work.scheduled[weekly], DateTime(2026, 10, 18, 20).difference(now));
  });

  test(
    'recurring on schedules once with the delay to the next 09:00',
    () async {
      await scheduler.apply(makeUserSettings());

      expect(work.scheduled[recurring], const Duration(hours: 1));
    },
  );

  test('master off cancels both', () async {
    await scheduler.apply(
      makeUserSettings(notificationsEnabled: false, weeklySummaryEnabled: true),
    );

    expect(work.scheduled, isEmpty);
    expect(work.cancelled, [weekly, recurring]);
  });

  test('defaults cancel weekly and schedule recurring', () async {
    await scheduler.apply(makeUserSettings());

    expect(work.cancelled, [weekly]);
    expect(work.scheduled.keys, [recurring]);
  });

  test('unchanged toggles do nothing unless forced', () async {
    await scheduler.apply(makeUserSettings());
    work.reset();

    await scheduler.apply(makeUserSettings(theme: 'dark'));
    expect(work.calls, 0);

    await scheduler.apply(makeUserSettings(theme: 'dark'), force: true);
    expect(work.calls, 2);
  });

  test('not ready: no calls', () async {
    work.isReady = false;

    await scheduler.apply(makeUserSettings(weeklySummaryEnabled: true));
    await scheduler.cancelAll();

    expect(work.calls, 0);
  });

  test('cancelAll cancels both and the next apply schedules again', () async {
    await scheduler.apply(makeUserSettings());
    work.reset();

    await scheduler.cancelAll();
    expect(work.cancelled, [weekly, recurring]);

    work.reset();
    await scheduler.apply(makeUserSettings());
    expect(work.scheduled.keys, [recurring]);
  });

  test('fixedDelay overrides the computed delays', () async {
    scheduler = BackgroundTaskScheduler(
      work: work,
      clock: () => now,
      fixedDelay: const Duration(minutes: 1),
      appLanguageCode: () => 'en',
    );

    await scheduler.apply(makeUserSettings(weeklySummaryEnabled: true));

    expect(work.scheduled, {
      weekly: const Duration(minutes: 1),
      recurring: const Duration(minutes: 1),
    });
  });

  group('rearm', () {
    test('schedules only the task that ran', () async {
      await scheduler.rearm(
        weekly,
        makeUserSettings(weeklySummaryEnabled: true),
      );

      expect(work.scheduled.keys, [weekly]);
      expect(work.cancelled, isEmpty);
    });

    test('cancels the task that ran when its toggle is off', () async {
      await scheduler.rearm(
        recurring,
        makeUserSettings(notificationsEnabled: false),
      );

      expect(work.cancelled, [recurring]);
      expect(work.scheduled, isEmpty);
    });

    test('not ready: no calls', () async {
      work.isReady = false;

      await scheduler.rearm(recurring, makeUserSettings());

      expect(work.calls, 0);
    });
  });

  group('first day of week', () {
    final weeklyOn = makeUserSettings(weeklySummaryEnabled: true);

    test('a Saturday start schedules Friday 20:00', () async {
      await scheduler.apply(
        makeUserSettings(
          weeklySummaryEnabled: true,
          firstDayOfWeek: FirstDayOfWeek.saturday,
        ),
      );

      expect(
        work.scheduled[weekly],
        DateTime(2026, 10, 16, 20).difference(now),
      );
    });

    test('unset with Bangla schedules Friday 20:00', () async {
      scheduler = BackgroundTaskScheduler(
        work: work,
        clock: () => now,
        appLanguageCode: () => 'bn',
      );

      await scheduler.apply(weeklyOn);

      expect(
        work.scheduled[weekly],
        DateTime(2026, 10, 16, 20).difference(now),
      );
    });

    test('changing it re-schedules with the new delay', () async {
      await scheduler.apply(weeklyOn);
      work.reset();

      await scheduler.apply(
        weeklyOn.copyWith(firstDayOfWeek: FirstDayOfWeek.sunday),
      );

      expect(
        work.scheduled[weekly],
        DateTime(2026, 10, 17, 20).difference(now),
      );
    });

    test('rearm uses the setting', () async {
      await scheduler.rearm(
        weekly,
        weeklyOn.copyWith(firstDayOfWeek: FirstDayOfWeek.sunday),
      );

      expect(
        work.scheduled[weekly],
        DateTime(2026, 10, 17, 20).difference(now),
      );
    });
  });

  group('app language change', () {
    var language = 'en';

    setUp(() {
      language = 'en';
      scheduler = BackgroundTaskScheduler(
        work: work,
        clock: () => now,
        appLanguageCode: () => language,
      );
    });

    test('re-arms an unset first day to the new default', () async {
      final settings = makeUserSettings(weeklySummaryEnabled: true);
      await scheduler.apply(settings);
      work.reset();

      language = 'bn';
      await scheduler.apply(settings);

      expect(
        work.scheduled[weekly],
        DateTime(2026, 10, 16, 20).difference(now),
      );
    });

    test('does nothing when the first day is stored', () async {
      final settings = makeUserSettings(
        weeklySummaryEnabled: true,
        firstDayOfWeek: FirstDayOfWeek.monday,
      );
      await scheduler.apply(settings);
      work.reset();

      language = 'bn';
      await scheduler.apply(settings);

      expect(work.calls, 0);
    });
  });
}
