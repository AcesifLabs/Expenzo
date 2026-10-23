import 'package:expense_tracker/i18n/strings.g.dart';

import 'failures.dart';

/// Error codes with their own user-facing text (see [failureText]).
abstract final class FailureCodes {
  static const notFound = 'NOT_FOUND';
  static const smsScan = 'SMS_SCAN_ERROR';

  /// Firebase wants a fresh sign-in before deleting the account.
  static const requiresRecentLogin = 'REQUIRES_RECENT_LOGIN';

  /// [Failure.message] is already user-facing text in the app language.
  static const userMessage = 'USER_MESSAGE';
}

/// The localized text a user sees for [failure].
///
/// `Failure.message` is diagnostic text for logs and is never shown, unless
/// the code is [FailureCodes.userMessage].
String failureText(Failure failure) {
  final errors = t.common.errors;

  switch (failure.errorCode) {
    case FailureCodes.notFound:
      return errors.notFound;
    case FailureCodes.smsScan:
      return errors.smsScan;
    case FailureCodes.requiresRecentLogin:
      return errors.requiresRecentLogin;
    case FailureCodes.userMessage:
      return failure.message;
  }

  return switch (failure) {
    NetworkFailure() => errors.network,
    ServerFailure() => errors.server,
    AuthFailure() => errors.auth,
    PermissionFailure() => errors.permission,
    CacheFailure() => errors.storage,
    _ when failure.errorCode == 'DB_ERROR' => errors.storage,
    _ => errors.generic,
  };
}
