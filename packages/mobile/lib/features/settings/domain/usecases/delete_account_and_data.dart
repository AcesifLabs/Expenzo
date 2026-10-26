import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/wipe_local_data.dart';

class DeleteAccountAndData implements UseCase<Unit, NoParams> {
  final AuthRepository authRepository;
  final WipeLocalData wipeLocalData;

  const DeleteAccountAndData({
    required this.authRepository,
    required this.wipeLocalData,
  });

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
