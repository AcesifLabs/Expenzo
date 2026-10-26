import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';
import '../entities/recurring_transaction.dart';
import 'get_recurring_list.dart';

abstract class RecurringReminderLog {
  Future<bool> wasSent(String key);
  Future<void> markSent(String key);
}

class SendRecurringReminders {
  final GetRecurringList getRecurringList;
  final GetSettings getSettings;
  final NotificationService notificationService;
  final RecurringReminderLog log;

  Future<void> _previous = Future.value();

  SendRecurringReminders({
    required this.getRecurringList,
    required this.getSettings,
    required this.notificationService,
    required this.log,
  });

  static DateTime reminderAt(DateTime dueDate) => DateTime(
    dueDate.year,
    dueDate.month,
    dueDate.day - 1,
    AppConstants.recurringReminderHour,
  );

  Future<Either<Failure, int>> call({required DateTime now}) {
    final result = _previous.then((_) => _send(now));
    _previous = result.then(_ignore, onError: _ignore);

    return result;
  }

  Future<Either<Failure, int>> _send(DateTime now) async {
    try {
      final settings = (await getSettings(
        NoParams(),
      )).fold((_) => null, (s) => s);
      if (settings == null ||
          !settings.isEnabled(NotificationToggle.recurringReminders)) {
        return const Right(0);
      }

      if (!await notificationService.canNotify()) return const Right(0);

      final list = await getRecurringList(NoParams());

      return await list.fold((failure) async => Left(failure), (items) async {
        var sent = 0;
        for (final item in items) {
          if (await _remindIfNeeded(item, now)) sent++;
        }

        return Right(sent);
      });
    } catch (e, s) {
      appLogger.error('Error sending recurring reminders', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<bool> _remindIfNeeded(RecurringTransaction item, DateTime now) async {
    final id = item.id;
    if (!item.isActive || id == null || !_inWindow(item, now)) return false;

    final key = '$id|${item.nextOccurrence.toUtc().toIso8601String()}';
    if (await log.wasSent(key)) return false;

    await notificationService.showRecurringDue(
      recurringId: id,
      description:
          '${item.description} · ${CurrencyFormatter.format(item.amount)}',
    );
    await log.markSent(key);

    return true;
  }

  static bool _inWindow(RecurringTransaction item, DateTime now) {
    final due = item.nextOccurrence.toLocal();
    final dueDayStart = DateTime(due.year, due.month, due.day);

    return !now.isBefore(reminderAt(due)) && now.isBefore(dueDayStart);
  }

  static Object? _ignore([Object? _]) => null;
}
