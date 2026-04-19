import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, User>> signInWithGoogle();
  Future<Either<AuthFailure, Unit>> signOut();
  Future<Either<AuthFailure, User?>> getCurrentUser();
  Future<Either<AuthFailure, bool>> isSignedIn();
  Future<Either<AuthFailure, Unit>> deleteAccount();
  Future<Either<AuthFailure, bool>> hasGmailScope();
}
