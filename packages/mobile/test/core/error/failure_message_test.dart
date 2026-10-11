import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/message_templates/data/repositories/message_template_repository_impl.dart';
import 'package:expense_tracker/features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test('each failure type maps to its own text, never the raw message', () {
    const raw = 'SqliteException(5): database is locked';
    final errors = t.common.errors;

    expect(failureText(const CacheFailure(message: raw)), errors.storage);
    expect(failureText(const NetworkFailure(message: raw)), errors.network);
    expect(failureText(const ServerFailure(message: raw)), errors.server);
    expect(failureText(const AuthFailure(message: raw)), errors.auth);
    expect(
      failureText(const PermissionFailure(message: raw)),
      errors.permission,
    );
  });

  test('a not-found code wins over the failure type', () {
    const failure = CacheFailure(
      message: 'Budget not found',
      errorCode: FailureCodes.notFound,
    );

    expect(failureText(failure), t.common.errors.notFound);
  });

  test('text follows the active language', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    expect(
      failureText(const NetworkFailure(message: 'offline')),
      t.common.errors.network,
    );
    expect(t.common.errors.network, isNot(contains('offline')));
  });

  test('a user-message failure shows its own text; other codes never do', () {
    const shown = AuthFailure(
      message: 'Sign-in was cancelled.',
      errorCode: FailureCodes.userMessage,
    );
    const hidden = AuthFailure(message: 'PlatformException(sign_in_failed)');

    expect(failureText(shown), 'Sign-in was cancelled.');
    expect(failureText(hidden), isNot(contains('PlatformException')));
  });

  test('SMS scan and database codes have their own text', () {
    expect(
      failureText(const SmsScanFailure(message: 'boom')),
      t.common.errors.smsScan,
    );
    expect(
      failureText(const DatabaseFailure(message: 'locked')),
      t.common.errors.storage,
    );
  });

  test('an unknown failure type falls back to the generic text', () {
    expect(failureText(const _OtherFailure()), t.common.errors.generic);
  });
}

class _OtherFailure extends Failure {
  const _OtherFailure() : super(message: 'internal', errorCode: 'OTHER');
}
