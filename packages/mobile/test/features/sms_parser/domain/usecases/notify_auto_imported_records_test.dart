import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/auto_imported_record.dart';
import 'package:expense_tracker/features/sms_parser/domain/usecases/notify_auto_imported_records.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

import '../../../../support/factories/user_settings_factory.dart';

class _MockGetSettings extends Mock implements GetSettings {}

class _MockNotificationService extends Mock implements NotificationService {}

AutoImportedRecord _record(String id, {String? description}) =>
    AutoImportedRecord(
      sourceId: id,
      amount: 500,
      description: description,
      sender: 'bKash',
      recordType: RecordType.expense,
    );

void main() {
  late _MockGetSettings getSettings;
  late _MockNotificationService notifications;
  late NotifyAutoImportedRecords notify;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(_record('fallback'));
  });

  setUp(() {
    getSettings = _MockGetSettings();
    notifications = _MockNotificationService();
    notify = NotifyAutoImportedRecords(
      getSettings: getSettings,
      notificationService: notifications,
    );
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => Right(makeUserSettings()));
    when(() => notifications.canNotify()).thenAnswer((_) async => true);
    when(
      () => notifications.showAutoImportedRecord(any()),
    ).thenAnswer((_) async {});
    when(
      () => notifications.showAutoImportSummary(count: any(named: 'count')),
    ).thenAnswer((_) async {});
  });

  void verifyNothingShown() {
    verifyNever(() => notifications.showAutoImportedRecord(any()));
    verifyNever(
      () => notifications.showAutoImportSummary(count: any(named: 'count')),
    );
  }

  test('one record shows that record', () async {
    await notify([_record('a', description: 'Daraz payment')]);

    verify(
      () => notifications.showAutoImportedRecord(
        _record('a', description: 'Daraz payment'),
      ),
    ).called(1);
    verifyNever(
      () => notifications.showAutoImportSummary(count: any(named: 'count')),
    );
  });

  test('several records show one summary', () async {
    await notify([_record('a'), _record('b'), _record('c')]);

    verify(() => notifications.showAutoImportSummary(count: 3)).called(1);
    verifyNever(() => notifications.showAutoImportedRecord(any()));
  });

  test('no records reads nothing and shows nothing', () async {
    await notify([]);

    verifyNever(() => getSettings(any()));
    verifyNothingShown();
  });

  test('the auto-import switch off shows nothing', () async {
    when(() => getSettings(any())).thenAnswer(
      (_) async => Right(makeUserSettings(autoImportAlertsEnabled: false)),
    );

    await notify([_record('a')]);

    verifyNothingShown();
  });

  test('the master switch off shows nothing', () async {
    when(() => getSettings(any())).thenAnswer(
      (_) async => Right(makeUserSettings(notificationsEnabled: false)),
    );

    await notify([_record('a')]);

    verifyNothingShown();
  });

  test('blocked system notifications show nothing', () async {
    when(() => notifications.canNotify()).thenAnswer((_) async => false);

    await notify([_record('a')]);

    verifyNothingShown();
  });

  test('a settings failure shows nothing', () async {
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'no settings')));

    await notify([_record('a')]);

    verifyNothingShown();
  });

  test('a notification error is swallowed', () async {
    when(
      () => notifications.showAutoImportSummary(count: any(named: 'count')),
    ).thenThrow(Exception('plugin failed'));

    await expectLater(notify([_record('a'), _record('b')]), completes);
  });
}
