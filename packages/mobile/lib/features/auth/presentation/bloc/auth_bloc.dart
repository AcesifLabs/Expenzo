import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/api/token_storage.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final AuthRepository _authRepository;
  StreamSubscription<void>? _firstSyncSub;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested, transformer: concurrent());
    on<SignInWithGoogleRequested>(
      _onSignInWithGoogleRequested,
      transformer: concurrent(),
    );
    on<SignOutRequested>(_onSignOutRequested, transformer: concurrent());
    on<FirstSyncRequested>(_onFirstSyncRequested, transformer: droppable());
    _firstSyncSub = _authRepository.firstSyncNeeded.listen(
      (_) => add(const FirstSyncRequested()),
    );
  }

  @override
  Future<void> close() async {
    await _firstSyncSub?.cancel();

    return super.close();
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUser(NoParams());
    final user = result.fold((f) => null, (u) => u);
    if (user == null) {
      emit(const Unauthenticated());

      return;
    }
    await _onAuthSuccess(user, emit);
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await signInWithGoogle(NoParams());
      final user = result.fold((f) => null, (u) => u);
      if (user == null) {
        emit(
          AuthError(
            result.fold((f) => failureText(f), (_) => t.common.errors.generic),
            isUserInitiated: true,
          ),
        );

        return;
      }
      await _onAuthSuccess(user, emit);
    } catch (e, s) {
      addError(e, s);
      emit(AuthError(t.common.errors.generic, isUserInitiated: true));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.stopSyncEngine();
    final result = await signOut(NoParams());
    result.fold(
      (failure) => emit(AuthError(failureText(failure))),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onFirstSyncRequested(
    FirstSyncRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! Authenticated) return;
    await _onAuthSuccess(current.user, emit);
  }

  /// With Sync off the conflict check is skipped: it talks to the server.
  /// The engine stays idle. Turning Sync on later runs this path
  /// ([FirstSyncRequested] from [SyncEngine.firstSyncNeeded]).
  ///
  /// When the check can't reach the server, the user is signed in but sync
  /// stays stopped: starting it would merge this phone's data into the
  /// account without asking. The check runs again on the next start, and
  /// when the user taps Sync now.
  Future<void> _onAuthSuccess(User user, Emitter<AuthState> emit) async {
    if (await TokenStorage.isFirstSync() &&
        await _authRepository.isSyncEnabled()) {
      try {
        final conflict = await _authRepository.checkConflict();
        if (conflict == SyncConflictType.conflict) {
          emit(AuthSyncConflictPending(user));

          return;
        }
      } catch (e, s) {
        appLogger.warning('AuthBloc: Conflict check failed; sync waits', e, s);
        emit(Authenticated(user));

        return;
      }
    }
    emit(Authenticated(user));
    unawaited(_tryStartSyncEngine());
  }

  Future<void> _tryStartSyncEngine() async {
    await _authRepository.startSyncEngine();
  }
}
