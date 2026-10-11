import 'package:expense_tracker/i18n/strings.g.dart';

import 'failures.dart';

/// Error codes with their own user-facing text (see [failureText]).
abstract final class FailureCodes {
  static const notFound = 'NOT_FOUND';
  static const smsScan = 'SMS_SCAN_ERROR';

  /// [Failure.message] is already user-facing text in the app language.
  static const userMessage = 'USER_MESSAGE';
}

/// The localized text a user sees for [failure].
///
/// `Failure.message` is diagnostic text for logs and is never shown, unless
/// the code is [FailureCodes.userMessage].
String failureText(Failure failure) {
  switch (failure.errorCode) {
    case FailureCodes.notFound:
      return t.common.errors.notFound;
    case FailureCodes.smsScan:
      return t.common.errors.smsScan;
    case FailureCodes.userMessage:
      return failure.message;
  }

  return switch (failure) {
    NetworkFailure() => t.common.errors.network,
    ServerFailure() => t.common.errors.server,
    AuthFailure() => t.common.errors.auth,
    PermissionFailure() => t.common.errors.permission,
    CacheFailure() => t.common.errors.storage,
    _ when failure.errorCode == 'DB_ERROR' => t.common.errors.storage,
    _ => t.common.errors.generic,
  };
}
