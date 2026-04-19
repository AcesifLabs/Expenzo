import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

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
      return Left(AuthFailure(message: e.toString()));
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
      return Left(AuthFailure(message: e.toString()));
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
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> isSignedIn() async {
    try {
      final isSignedIn = await remoteDatasource.isSignedIn();
      return Right(isSignedIn);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
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
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> hasGmailScope() async {
    try {
      final hasScope = await remoteDatasource.hasGmailScope();
      return Right(hasScope);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
