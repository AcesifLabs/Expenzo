import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/wipe_local_data.dart';

/// Delete account (Q22): re-auth, delete the account and its synced data on
/// the server, wipe this phone's data, then delete the Firebase user and sign
/// out. Nothing is deleted when re-auth or the server step fails. Sync stays
/// paused throughout, so no cycle pushes into the account mid-delete.
class DeleteAccountAndData implements UseCase<Unit, NoParams> {
  final AuthRepository authRepository;
  final WipeLocalData wipeLocalData;

  const DeleteAccountAndData({
    required this.authRepository,
    required this.wipeLocalData,
  });

  /// Returns [Left] only when nothing was deleted, as far as this phone
  /// knows. (A lost response can hide a server delete; on the next request's
  /// deleted-user 401 the API client signs out instead of re-creating the
  /// account.) Once the server delete succeeds
  /// there is no account left to retry against, so later failures are
  /// logged and the result is [Right].
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    await authRepository.pauseSyncEngine();
    try {
      final reauth = await authRepository.reauthenticate();
      if (reauth.isLeft()) return reauth;
      final server = await authRepository.deleteServerAccount();
      if (server.isLeft()) return server;
      await _deleteLocally();

      return const Right(unit);
    } finally {
      // Signed out after a delete, so sync stays idle; after an early
      // failure it starts again for the still-signed-in user.
      // Not awaited: restarting runs a whole sync cycle, and the result
      // (and the screen's busy state) mustn't wait for it.
      unawaited(authRepository.resumeSyncEngine());
    }
  }

  Future<void> _deleteLocally() async {
    try {
      final wipe = await wipeLocalData(NoParams());
      final failure = wipe.fold((f) => f, (_) => null);
      if (failure != null) {
        appLogger.error('Delete account: local wipe failed', failure);
      }
    } catch (e, s) {
      appLogger.error('Delete account: local wipe threw', e, s);
    }
    try {
      final deleted = await authRepository.deleteAccount();
      final failure = deleted.fold((f) => f, (_) => null);
      if (failure != null) {
        appLogger.error('Delete account: Firebase delete failed', failure);
      }
    } catch (e, s) {
      appLogger.error('Delete account: Firebase delete threw', e, s);
    }
  }
}
