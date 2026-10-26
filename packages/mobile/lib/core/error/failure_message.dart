import 'package:expense_tracker/i18n/strings.g.dart';

import 'failures.dart';

abstract final class FailureCodes {
  static const notFound = 'NOT_FOUND';
  static const smsScan = 'SMS_SCAN_ERROR';

  static const requiresRecentLogin = 'REQUIRES_RECENT_LOGIN';

  static const userMessage = 'USER_MESSAGE';

  static const alreadyInGroup = 'ALREADY_IN_GROUP';
  static const currencyMismatch = 'CURRENCY_MISMATCH';
  static const groupFull = 'GROUP_FULL';
  static const inviteExpired = 'INVITE_EXPIRED';
  static const inviteNotFound = 'INVITE_NOT_FOUND';
  static const lastAdmin = 'LAST_ADMIN';
  static const notInGroup = 'NOT_IN_GROUP';
}

String failureText(Failure failure) {
  final errors = t.common.errors;
  final family = t.family.errors;

  switch (failure.errorCode) {
    case FailureCodes.alreadyInGroup:
      return family.alreadyInGroup;
    case FailureCodes.currencyMismatch:
      return family.currencyMismatch;
    case FailureCodes.groupFull:
      return family.groupFull;
    case FailureCodes.inviteExpired:
      return family.inviteExpired;
    case FailureCodes.inviteNotFound:
      return family.inviteNotFound;
    case FailureCodes.lastAdmin:
      return family.lastAdmin;
    case FailureCodes.notInGroup:
      return family.notInGroup;
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
