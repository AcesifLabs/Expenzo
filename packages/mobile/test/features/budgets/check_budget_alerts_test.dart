import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

import '../../support/factories/user_settings_factory.dart';

class _MockGetBudgetsWithProgress extends Mock
    implements GetBudgetsWithProgress {}

class _MockGetSettings extends Mock implements GetSettings {}

class _MockNotificationService extends Mock implements NotificationService {}

class _MemoryAlertLog implements BudgetAlertLog {
  final sent = <String>{};

  @override
  Future<bool> wasSent(String key) async => sent.contains(key);

  @override
  Future<void> markSent(Iterable<String> keys) async => sent.addAll(keys);
}

BudgetProgress _progress(double percentage, {DateTime? periodStart}) {
  final start = periodStart ?? DateTime(2026, 10);

  return BudgetProgress(
    budgetId: 'b1',
    budgetAmount: 100,
    effectiveAmount: 100,
    spentAmount: percentage,
    rolloverAmount: 0,
    percentage: percentage,
    isOverBudget: percentage > 100,
    name: 'Food',
    periodRange: DateTimeRange(
      start: start,
      end: DateTime(start.year, start.month + 1),
    ),
    period: BudgetPeriod.monthly,
  );
}

void main() {
  late _MockGetBudgetsWithProgress getProgress;
  late _MockGetSettings getSettings;
  late _MockNotificationService notifications;
  late _MemoryAlertLog log;
  late CheckBudgetAlerts checkAlerts;

  setUpAll(() {
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    getProgress = _MockGetBudgetsWithProgress();
    getSettings = _MockGetSettings();
    notifications = _MockNotificationService();
    log = _MemoryAlertLog();
    checkAlerts = CheckBudgetAlerts(
      getBudgetsWithProgress: getProgress,
      getSettings: getSettings,
      notificationService: notifications,
      alertLog: log,
    );
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => Right(makeUserSettings()));
    when(() => notifications.canNotify()).thenAnswer((_) async => true);
    when(
      () => notifications.showBudgetAlert(
        budgetId: any(named: 'budgetId'),
        budgetName: any(named: 'budgetName'),
        percentage: any(named: 'percentage'),
        isOver: any(named: 'isOver'),
      ),
    ).thenAnswer((_) async {});
  });

  void spending(List<BudgetProgress> budgets) {
    when(() => getProgress()).thenAnswer((_) async => Right(budgets));
  }

  void expectNoAlert() => verifyNever(
    () => notifications.showBudgetAlert(
      budgetId: any(named: 'budgetId'),
      budgetName: any(named: 'budgetName'),
      percentage: any(named: 'percentage'),
      isOver: any(named: 'isOver'),
    ),
  );

  int alertsSent() => verify(
    () => notifications.showBudgetAlert(
      budgetId: any(named: 'budgetId'),
      budgetName: any(named: 'budgetName'),
      percentage: any(named: 'percentage'),
      isOver: any(named: 'isOver'),
    ),
  ).callCount;

  test('nothing is sent while the Settings switch is off', () async {
    when(() => getSettings(any())).thenAnswer(
      (_) async => Right(makeUserSettings(notificationsEnabled: false)),
    );
    spending([_progress(95)]);

    await checkAlerts();

    verifyNever(() => getProgress());
    expectNoAlert();
  });

  test('without notification permission nothing is sent or logged', () async {
    when(() => notifications.canNotify()).thenAnswer((_) async => false);
    spending([_progress(95)]);
    await checkAlerts();
    expectNoAlert();

    // Once the user allows notifications, the alert still goes out.
    when(() => notifications.canNotify()).thenAnswer((_) async => true);
    await checkAlerts();
    expect(alertsSent(), 1);
  });

  test('overlapping checks send an alert only once', () async {
    spending([_progress(95)]);
    await Future.wait([checkAlerts(), checkAlerts()]);

    expect(alertsSent(), 1);
  });

  test('below 80% stays quiet', () async {
    spending([_progress(79.9)]);

    await checkAlerts();

    expectNoAlert();
  });

  test('80% alerts once per period, however many records follow', () async {
    spending([_progress(80)]);

    await checkAlerts();
    await checkAlerts();
    spending([_progress(90)]);
    await checkAlerts();

    expect(alertsSent(), 1);
  });

  test('going over sends a second, separate alert', () async {
    spending([_progress(85)]);
    await checkAlerts();
    spending([_progress(120)]);
    await checkAlerts();

    expect(alertsSent(), 2);
  });

  test('jumping straight past 100% sends one alert, not two', () async {
    spending([_progress(130)]);
    await checkAlerts();
    spending([_progress(135)]);
    await checkAlerts();

    expect(alertsSent(), 1);
  });

  test('exactly at the limit is not reported as over', () async {
    spending([_progress(100)]);
    await checkAlerts();

    verify(
      () => notifications.showBudgetAlert(
        budgetId: 'b1',
        budgetName: 'Food',
        percentage: 100,
        isOver: false,
      ),
    ).called(1);
  });

  test('going past the limit is reported as over', () async {
    spending([_progress(101)]);
    await checkAlerts();

    verify(
      () => notifications.showBudgetAlert(
        budgetId: 'b1',
        budgetName: 'Food',
        percentage: 101,
        isOver: true,
      ),
    ).called(1);
  });

  test('a new budget period alerts again', () async {
    spending([_progress(85, periodStart: DateTime(2026, 10))]);
    await checkAlerts();
    spending([_progress(85, periodStart: DateTime(2026, 11))]);
    await checkAlerts();

    expect(alertsSent(), 2);
  });

  group('per-level toggles', () {
    void settingsWith({bool over = true, bool nearLimit = true}) {
      when(() => getSettings(any())).thenAnswer(
        (_) async => Right(
          makeUserSettings(
            budgetOverAlertsEnabled: over,
            budgetNearLimitAlertsEnabled: nearLimit,
          ),
        ),
      );
    }

    test('over-budget toggle off sends the 80% alert instead when the budget '
        'is over', () async {
      settingsWith(over: false);
      spending([_progress(120)]);

      await checkAlerts();

      verify(
        () => notifications.showBudgetAlert(
          budgetId: 'b1',
          budgetName: 'Food',
          percentage: 120,
          isOver: false,
        ),
      ).called(1);
    });

    test('80% toggle off sends nothing at 85% and logs nothing', () async {
      settingsWith(nearLimit: false);
      spending([_progress(85)]);

      await checkAlerts();

      expectNoAlert();
      expect(log.sent, isEmpty);
    });

    test('80% toggle off still sends the over alert at 120%', () async {
      settingsWith(nearLimit: false);
      spending([_progress(120)]);

      await checkAlerts();

      verify(
        () => notifications.showBudgetAlert(
          budgetId: 'b1',
          budgetName: 'Food',
          percentage: 120,
          isOver: true,
        ),
      ).called(1);
    });

    test('both toggles off skips loading budgets', () async {
      settingsWith(over: false, nearLimit: false);
      spending([_progress(120)]);

      await checkAlerts();

      verifyNever(() => getProgress());
      expectNoAlert();
    });
  });
}
