import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final AuthRepository _authRepository;

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
            result.fold((f) => f.message, (_) => 'Unknown error'),
            isUserInitiated: true,
          ),
        );

        return;
      }
      await _onAuthSuccess(user, emit);
    } catch (e, s) {
      addError(e, s);
      emit(AuthError(e.toString(), isUserInitiated: true));
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
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onAuthSuccess(User user, Emitter<AuthState> emit) async {
    if (await TokenStorage.isFirstSync()) {
      try {
        final conflict = await _authRepository.checkConflict();
        if (conflict == SyncConflictType.conflict) {
          emit(AuthSyncConflictPending(user));

          return;
        }
      } catch (e, s) {
        addError(e, s);
        debugPrint('AuthBloc: Conflict check failed, proceeding with auth: $e');
      }
    }
    emit(Authenticated(user));
    unawaited(_tryStartSyncEngine());
  }

  Future<void> _tryStartSyncEngine() async {
    await _authRepository.startSyncEngine();
  }
}
