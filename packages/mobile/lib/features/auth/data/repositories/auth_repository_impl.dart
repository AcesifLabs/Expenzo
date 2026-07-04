import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @visibleForTesting
  static String mapExceptionToMessage(Object e) {
    if (e is DioException) {
      final type = e.type;
      if (type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.receiveTimeout ||
          type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        return 'Unable to connect. Please check your internet connection and try again.';
      }

      return 'Something went wrong on our end. Please try again later.';
    }

    if (e is fb.FirebaseAuthException) {
      return _mapFirebaseAuthException(e);
    }

    if (e is PlatformException) {
      return _mapPlatformException(e);
    }

    if (e is TimeoutException) {
      return 'The request timed out. Please check your connection and try again.';
    }

    return 'Something went wrong. Please try again.';
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<AuthFailure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDatasource.signInWithGoogle();

      return Right(user);
    } on AuthException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      await remoteDatasource.signOut();

      return const Right(unit);
    } on AuthException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<AuthFailure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDatasource.getCurrentUser();

      return Right(user);
    } on AuthException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<AuthFailure, bool>> isSignedIn() async {
    try {
      final isSignedIn = await remoteDatasource.isSignedIn();

      return Right(isSignedIn);
    } catch (e) {
      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<AuthFailure, Unit>> deleteAccount() async {
    try {
      await remoteDatasource.deleteAccount();

      return const Right(unit);
    } on AuthException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<AuthFailure, bool>> hasGmailScope() async {
    try {
      final hasScope = await remoteDatasource.hasGmailScope();

      return Right(hasScope);
    } catch (e) {
      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
  }

  @override
  Future<SyncConflictType> checkConflict() async {
    return di.getIt<SyncEngine>().checkConflict();
  }

  @override
  Future<void> stopSyncEngine() async {
    try {
      await di.getIt<SyncEngine>().stop();
    } catch (_) {}
  }

  @override
  Future<void> startSyncEngine() async {
    try {
      await di.getIt<SyncEngine>().start();
    } catch (_) {}
  }

  static String _mapFirebaseAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-cancelled':
      case 'cancelled':
        return 'Sign-in was cancelled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static String _mapPlatformException(PlatformException e) {
    if (e.code == 'network_error' || e.code == 'network-error') {
      return 'Network error. Please check your connection and try again.';
    }

    if (e.code == 'sign_in_canceled' || e.code == 'sign_in_failed') {
      return 'Sign-in was cancelled.';
    }

    return 'Authentication failed. Please try again.';
  }
}
