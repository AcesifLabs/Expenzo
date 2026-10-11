import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import '../../../../shared/services/notification_service.dart';

/// Remembers which budget alerts were already sent.
abstract class BudgetAlertLog {
  Future<bool> wasSent(String key);

  /// Records [keys] as sent, in one write.
  Future<void> markSent(Iterable<String> keys);
}

enum BudgetAlertLevel { nearLimit, over }

/// Sends a Budget Alert (CONTEXT.md) after records change.
///
/// Each budget gets at most one alert at 80% and one when it goes over, per
/// budget period. Nothing is sent while the master switch is off; each level
/// has its own toggle (Settings → Notifications).
class CheckBudgetAlerts {
  static const nearLimitPercent = 80.0;

  final GetBudgetsWithProgress getBudgetsWithProgress;
  final GetSettings getSettings;
  final NotificationService notificationService;
  final BudgetAlertLog alertLog;

  /// The previous check, so overlapping calls (a save while an SMS is being
  /// imported) run one after another instead of both sending the same alert.
  Future<void> _previous = Future.value();

  CheckBudgetAlerts({
    required this.getBudgetsWithProgress,
    required this.getSettings,
    required this.notificationService,
    required this.alertLog,
  });

  Future<Either<Failure, Unit>> call() {
    final result = _previous.then((_) => _check());
    // Only the ordering matters here; the result and any error reach the
    // caller through [result].
    _previous = result.then(_ignore, onError: _ignore);

    return result;
  }

  static BudgetAlertLevel? levelFor(BudgetProgress budget) {
    if (budget.isOverBudget || budget.percentage > 100) {
      return BudgetAlertLevel.over;
    }
    if (budget.percentage >= nearLimitPercent) {
      return BudgetAlertLevel.nearLimit;
    }

    return null;
  }

  /// One key per budget, period and level, so a new period alerts again.
  static String alertKey(BudgetProgress budget, BudgetAlertLevel level) {
    final period = budget.periodRange.start.toIso8601String();

    return '${budget.budgetId}|$period|${level.name}';
  }

  Future<Either<Failure, Unit>> _check() async {
    try {
      final result = await getSettings(NoParams());
      final settings = result.fold((_) => null, (s) => s);
      if (settings == null ||
          (!settings.isEnabled(NotificationToggle.budgetOver) &&
              !settings.isEnabled(NotificationToggle.budgetNearLimit))) {
        return const Right(unit);
      }
      // Without permission the alert would be dropped but still logged as
      // sent; skip it so it goes out once the user allows notifications.
      if (!await notificationService.canNotify()) return const Right(unit);

      final progress = await getBudgetsWithProgress();

      return await progress.fold((failure) async => Left(failure), (
        budgets,
      ) async {
        for (final budget in budgets) {
          await _alertIfNeeded(budget, settings);
        }

        return const Right(unit);
      });
    } catch (e, s) {
      appLogger.error('Error checking budget alerts', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<void> _alertIfNeeded(
    BudgetProgress budget,
    UserSettings settings,
  ) async {
    final level = _levelToSend(budget, settings);
    if (level == null) return;

    final key = alertKey(budget, level);
    if (await alertLog.wasSent(key)) return;

    await notificationService.showBudgetAlert(
      budgetId: budget.budgetId,
      budgetName: budget.name,
      percentage: budget.percentage,
      isOver: level == BudgetAlertLevel.over,
    );
    await alertLog.markSent([
      key,
      // Going straight past 80% shouldn't send a second, older alert later.
      if (level == BudgetAlertLevel.over)
        alertKey(budget, BudgetAlertLevel.nearLimit),
    ]);
  }

  /// The level to send under the user's toggles. With the over toggle off,
  /// an over budget still gets the 80% heads-up if that toggle is on.
  static BudgetAlertLevel? _levelToSend(
    BudgetProgress budget,
    UserSettings settings,
  ) {
    final nearLimitOn = settings.isEnabled(NotificationToggle.budgetNearLimit);

    return switch (levelFor(budget)) {
      BudgetAlertLevel.over
          when settings.isEnabled(NotificationToggle.budgetOver) =>
        BudgetAlertLevel.over,
      BudgetAlertLevel.over ||
      BudgetAlertLevel.nearLimit when nearLimitOn => BudgetAlertLevel.nearLimit,
      _ => null,
    };
  }

  static Object? _ignore([Object? _]) => null;
}
