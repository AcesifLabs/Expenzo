import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/get_recurring_list.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/send_recurring_reminders.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

import '../../../../support/factories/recurring_factory.dart';
import '../../../../support/factories/user_settings_factory.dart';

class _MockGetRecurringList extends Mock implements GetRecurringList {}

class _MockGetSettings extends Mock implements GetSettings {}

class _MockNotificationService extends Mock implements NotificationService {}

class _MemoryReminderLog implements RecurringReminderLog {
  final sent = <String>{};

  @override
  Future<bool> wasSent(String key) async => sent.contains(key);

  @override
  Future<void> markSent(String key) async => sent.add(key);
}

void main() {
  late _MockGetRecurringList getList;
  late _MockGetSettings getSettings;
  late _MockNotificationService notifications;
  late _MemoryReminderLog log;
  late SendRecurringReminders sendReminders;

  final tomorrow = DateTime(2026, 10, 13);
  final nineToday = DateTime(2026, 10, 12, 9);

  setUpAll(() {
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    getList = _MockGetRecurringList();
    getSettings = _MockGetSettings();
    notifications = _MockNotificationService();
    log = _MemoryReminderLog();
    sendReminders = SendRecurringReminders(
      getRecurringList: getList,
      getSettings: getSettings,
      notificationService: notifications,
      log: log,
    );
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => Right(makeUserSettings()));
    when(() => notifications.canNotify()).thenAnswer((_) async => true);
    when(
      () => notifications.showRecurringDue(
        recurringId: any(named: 'recurringId'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async {});
  });

  void recurring(List<RecurringTransaction> items) {
    when(() => getList(any())).thenAnswer((_) async => Right(items));
  }

  void expectNothingSent() => verifyNever(
    () => notifications.showRecurringDue(
      recurringId: any(named: 'recurringId'),
      description: any(named: 'description'),
    ),
  );

  test('toggle off sends nothing and does not load the list', () async {
    when(() => getSettings(any())).thenAnswer(
      (_) async => Right(makeUserSettings(recurringRemindersEnabled: false)),
    );
    recurring([makeRecurring(nextOccurrence: tomorrow)]);

    expect(await sendReminders(now: nineToday), const Right<Failure, int>(0));
    verifyNever(() => getList(any()));
    expectNothingSent();
  });

  test('master off sends nothing', () async {
    when(() => getSettings(any())).thenAnswer(
      (_) async => Right(makeUserSettings(notificationsEnabled: false)),
    );
    recurring([makeRecurring(nextOccurrence: tomorrow)]);

    await sendReminders(now: nineToday);

    verifyNever(() => getList(any()));
  });

  test('due tomorrow, at 09:00 today, sends once with description and '
      'amount', () async {
    recurring([
      makeRecurring(
        id: 'r1',
        description: 'Rent',
        amount: 500,
        nextOccurrence: tomorrow,
      ),
    ]);

    expect(await sendReminders(now: nineToday), const Right<Failure, int>(1));
    verify(
      () => notifications.showRecurringDue(
        recurringId: 'r1',
        description: 'Rent · ${CurrencyFormatter.format(500)}',
      ),
    ).called(1);
  });

  test('due tomorrow, at 08:59 today, sends nothing', () async {
    recurring([makeRecurring(nextOccurrence: tomorrow)]);

    await sendReminders(now: DateTime(2026, 10, 12, 8, 59));

    expectNothingSent();
  });

  test('a later run the same day still sends; a second run does not', () async {
    recurring([makeRecurring(nextOccurrence: tomorrow)]);

    await sendReminders(now: DateTime(2026, 10, 12, 13));
    await sendReminders(now: DateTime(2026, 10, 12, 18));

    verify(
      () => notifications.showRecurringDue(
        recurringId: any(named: 'recurringId'),
        description: any(named: 'description'),
      ),
    ).called(1);
  });

  test('overlapping runs send a reminder only once', () async {
    recurring([makeRecurring(nextOccurrence: tomorrow)]);

    await Future.wait([
      sendReminders(now: nineToday),
      sendReminders(now: nineToday),
    ]);

    verify(
      () => notifications.showRecurringDue(
        recurringId: any(named: 'recurringId'),
        description: any(named: 'description'),
      ),
    ).called(1);
  });

  test('the next occurrence gets a new reminder', () async {
    recurring([makeRecurring(nextOccurrence: tomorrow)]);
    await sendReminders(now: nineToday);
    recurring([makeRecurring(nextOccurrence: DateTime(2026, 11, 13))]);
    await sendReminders(now: DateTime(2026, 11, 12, 9));

    expect(log.sent, hasLength(2));
  });

  test(
    'far future, inactive, due-today and overdue items are skipped',
    () async {
      recurring([
        makeRecurring(id: 'far', nextOccurrence: DateTime(2026, 10, 15)),
        makeRecurring(id: 'off', nextOccurrence: tomorrow, isActive: false),
        makeRecurring(id: 'today', nextOccurrence: DateTime(2026, 10, 12)),
        makeRecurring(id: 'late', nextOccurrence: DateTime(2026, 10, 1)),
      ]);

      await sendReminders(now: nineToday);

      expectNothingSent();
    },
  );

  test('without permission nothing is sent or logged', () async {
    when(() => notifications.canNotify()).thenAnswer((_) async => false);
    recurring([makeRecurring(nextOccurrence: tomorrow)]);

    await sendReminders(now: nineToday);

    expectNothingSent();
    expect(log.sent, isEmpty);
  });

  test('a list failure returns Left', () async {
    when(
      () => getList(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db')));

    expect((await sendReminders(now: nineToday)).isLeft(), isTrue);
  });

  test('reminderAt is 09:00 the day before, across a month start', () {
    expect(
      SendRecurringReminders.reminderAt(DateTime(2026, 11, 1)),
      DateTime(2026, 10, 31, 9),
    );
    expect(
      SendRecurringReminders.reminderAt(DateTime(2027, 1, 1)),
      DateTime(2026, 12, 31, 9),
    );
  });
}
