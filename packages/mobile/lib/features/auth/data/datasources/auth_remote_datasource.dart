import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/database/app_database.dart' show UsersCompanion;
import '../../../../core/database/daos/user_dao.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import '../../../../core/api/token_storage.dart';
import '../../domain/entities/user.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

abstract class AuthRemoteDatasource {
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<bool> isSignedIn();

  /// Signs in to Google again silently and refreshes the Firebase session,
  /// so a later account delete can't fail with `requires-recent-login`.
  ///
  /// Throws: [RequiresRecentLoginException] when there is no Firebase user or
  /// Google needs the user to pick the account again; Firebase or platform
  /// errors otherwise.
  Future<void> reauthenticate();

  /// Deletes the account and everything synced to it on the server
  /// (`DELETE /auth/account`), then drops the JWT. Completes normally when
  /// an earlier attempt already deleted it (a lost response).
  ///
  /// Throws: [AuthException] on 401, [NetworkException] when the server
  /// can't be reached, [ServerException] otherwise.
  Future<void> deleteServerAccount();

  /// Deletes the Firebase user, then signs out of Google and Firebase and
  /// clears tokens and the local user, even when the delete fails.
  ///
  /// Throws: [RequiresRecentLoginException] when Firebase still wants a
  /// fresh sign-in; Firebase errors otherwise.
  Future<void> deleteAccount();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final GoogleSignIn googleSignIn;
  final fb.FirebaseAuth firebaseAuth;
  final UserDao userDao;
  final ApiClient apiClient;

  static const _connectionErrors = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  };

  AuthRemoteDatasourceImpl({
    required this.googleSignIn,
    required this.firebaseAuth,
    required this.userDao,
    required this.apiClient,
  });

  @override
  Future<User> signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw AuthException(message: t.auth.errors.cancelled);
    }

    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw AuthException(message: t.auth.errors.failed);
    }

    final user = _mapFirebaseUserToEntity(firebaseUser);
    await _syncUserToLocalDb(firebaseUser);
    await _obtainJwtToken(firebaseUser);

    return user;
  }

  @override
  Future<void> signOut() async {
    await TokenStorage.clearAll();
    await userDao.clearUser();
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) return null;
    await _syncUserToLocalDb(firebaseUser);

    return _mapFirebaseUserToEntity(firebaseUser);
  }

  @override
  Future<bool> isSignedIn() async {
    final currentUser = firebaseAuth.currentUser;

    return currentUser != null;
  }

  @override
  Future<void> reauthenticate() async {
    final user = firebaseAuth.currentUser;
    // Without a Firebase session the delete can't finish, so stop before the
    // server step rather than leave a Firebase user behind.
    if (user == null) {
      throw const RequiresRecentLoginException(
        message: 'No Firebase user to re-authenticate',
      );
    }
    await _reauthenticate(user);
  }

  @override
  Future<void> deleteServerAccount() async {
    try {
      await apiClient.dio.delete(ApiConstants.deleteAccount);
    } on DioException catch (e) {
      // A retry after a lost response: the JWT's user is already gone.
      // No 404 shortcut: a deleted user gets this 401 from the JWT check, so
      // a 404 means a wrong route or an old backend.
      if (!isDeletedUserResponse(e.response)) throw _exceptionFor(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
    // Drop the JWT now, not after the local wipe: nothing may use it against
    // the deleted account in between.
    await _bestEffort(TokenStorage.clearAll);
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _deleteFirebaseUser();
    } finally {
      // Tokens first: a JWT left behind lets sync's 401 refresh log in again
      // and re-create the deleted server account. Each step runs even if an
      // earlier one throws, and never hides the delete's own error.
      await _bestEffort(TokenStorage.clearAll);
      await _bestEffort(userDao.clearUser);
      await _bestEffort(googleSignIn.signOut);
      await _bestEffort(firebaseAuth.signOut);
    }
  }

  Future<void> _deleteFirebaseUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;
    try {
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      // [reauthenticate] runs first, so this is only a safety net.
      if (e.code != 'requires-recent-login') rethrow;
      await _reauthenticate(user);
      await user.delete();
    }
  }

  static Future<void> _bestEffort(Future<Object?> Function() step) async {
    try {
      await step();
    } catch (e) {
      debugPrint('AuthRemoteDatasource: Cleanup step failed: ${e.runtimeType}');
    }
  }

  Future<void> _reauthenticate(fb.User user) async {
    final googleAccount = await googleSignIn.signInSilently();
    if (googleAccount == null) {
      throw const RequiresRecentLoginException(
        message: 'Silent Google sign-in returned no account',
      );
    }
    final googleAuth = await googleAccount.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  static Exception _exceptionFor(DioException e) {
    final message = e.message ?? e.type.name;
    final status = e.response?.statusCode;
    if (status == 401) return AuthException(message: message);
    if (_connectionErrors.contains(e.type)) {
      return NetworkException(message: message);
    }

    return ServerException(message: message, statusCode: status);
  }

  User _mapFirebaseUserToEntity(fb.User user) {
    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<void> _syncUserToLocalDb(fb.User firebaseUser) async {
    try {
      final now = DateTime.now().toUtc();
      await userDao.upsertUser(
        UsersCompanion.insert(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: Value(firebaseUser.displayName),
          photoUrl: Value(firebaseUser.photoURL),
          createdAt: Value(now),
          lastLoginAt: Value(now),
        ),
      );
    } catch (e) {
      debugPrint(
        'AuthRemoteDatasource: Failed to sync user to local DB: ${e.runtimeType}',
      );
    }
  }

  Future<void> _obtainJwtToken(fb.User firebaseUser) async {
    final firebaseToken = await firebaseUser.getIdToken(true);
    final response = await apiClient.dio.post(
      ApiConstants.login,
      data: {'firebaseToken': firebaseToken},
    );
    final accessToken = response.data['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw ServerException(
        message: 'Invalid access token received from server.',
      );
    }
    await TokenStorage.saveToken(accessToken);
  }
}
