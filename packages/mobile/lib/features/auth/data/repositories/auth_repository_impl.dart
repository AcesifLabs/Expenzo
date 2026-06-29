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

    debugPrint('AuthRepositoryImpl: Unmapped exception type: ${e.runtimeType}');

    return 'Something went wrong. Please try again.';
  }

  @override
  Future<Either<AuthFailure, User>> signInWithGoogle() async {
    try {
      debugPrint('AuthRepositoryImpl: signInWithGoogle called');
      final user = await remoteDatasource.signInWithGoogle();
      debugPrint('AuthRepositoryImpl: signInWithGoogle success, user: $user');

      return Right(user);
    } on AuthException catch (e) {
      debugPrint('AuthRepositoryImpl: AuthException: ${e.message}');

      return Left(e.toFailure());
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Exception: $e\n$stackTrace');

      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
  }

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

  @override
  Future<Either<AuthFailure, bool>> isSignedIn() async {
    try {
      final isSignedIn = await remoteDatasource.isSignedIn();

      return Right(isSignedIn);
    } catch (e) {
      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
  }

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

  @override
  Future<Either<AuthFailure, bool>> hasGmailScope() async {
    try {
      final hasScope = await remoteDatasource.hasGmailScope();

      return Right(hasScope);
    } catch (e) {
      return Left(AuthFailure(message: mapExceptionToMessage(e)));
    }
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

    debugPrint(
      'AuthRepositoryImpl: Unhandled PlatformException code: ${e.code}',
    );

    return 'Authentication failed. Please try again.';
  }
}
