import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/background/background_task_scheduler.dart';
import 'package:expense_tracker/core/di/data_wipe_module.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

class _MockNotifications extends Mock implements NotificationService {}

class _MockScheduler extends Mock implements BackgroundTaskScheduler {}

void main() {
  late GetIt getIt;

  setUp(() => getIt = GetIt.asNewInstance());

  test('cancels notifications and background tasks when registered', () async {
    final notifications = _MockNotifications();
    final scheduler = _MockScheduler();
    when(() => notifications.cancelAll()).thenAnswer((_) async {});
    when(() => scheduler.cancelAll()).thenAnswer((_) async {});
    getIt
      ..registerSingleton<NotificationService>(notifications)
      ..registerSingleton<BackgroundTaskScheduler>(scheduler);

    await cancelScheduledWork(getIt);

    verify(() => notifications.cancelAll()).called(1);
    verify(() => scheduler.cancelAll()).called(1);
  });

  test('skips what feature dependencies have not registered yet', () async {
    await expectLater(cancelScheduledWork(getIt), completes);
  });
}
