import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/database/app_database.dart' show UsersCompanion;
import '../../../../core/database/daos/user_dao.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import '../../../../core/api/token_storage.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDatasource {
  /// Throws: [ServerException] if the API request fails.
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<bool> isSignedIn();
  Future<void> deleteAccount();

  /// Throws: [ServerException] if the API request fails.
  Future<bool> hasGmailScope();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final GoogleSignIn googleSignIn;
  final fb.FirebaseAuth firebaseAuth;
  final UserDao userDao;

  AuthRemoteDatasourceImpl({
    required this.googleSignIn,
    required this.firebaseAuth,
    required this.userDao,
  });

  /// Throws: [ServerException] if the API request fails.
  @override
  Future<User> signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw AuthException(message: 'Google sign in was cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw AuthException(message: 'Firebase sign in failed');
    }

    final user = _mapFirebaseUserToEntity(firebaseUser);
    await _syncUserToLocalDb(firebaseUser);
    await _obtainJwtToken(firebaseUser);

    return user;
  }

  /// Throws: [ServerException] if the API request fails.
  @override
  Future<void> signOut() async {
    await TokenStorage.clearAll();
    await userDao.clearUser();
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  /// Throws: [ServerException] if the API request fails.
  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) return null;
    await _syncUserToLocalDb(firebaseUser);

    return _mapFirebaseUserToEntity(firebaseUser);
  }

  /// Throws: [ServerException] if the API request fails.
  @override
  Future<bool> isSignedIn() async {
    final currentUser = firebaseAuth.currentUser;

    return currentUser != null;
  }

  /// Throws: [ServerException] if the API request fails.
  /// Handles the common `requires-recent-login` exception by re-authenticating
  /// via Google Sign-In before retrying the delete.
  @override
  Future<void> deleteAccount() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Re-authenticate via Google credential and retry
        final googleAccount = await googleSignIn.signInSilently();
        if (googleAccount == null) {
          throw ServerException(
            message:
                'Re-authentication required. Please sign in again before deleting your account.',
          );
        }
        final googleAuth = await googleAccount.authentication;
        final credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
        await user.delete();
      } else {
        rethrow;
      }
    }

    // Cleanup: sign out of Google, clear tokens, clear local user
    await googleSignIn.signOut();
    await TokenStorage.clearAll();
    await userDao.clearUser();
  }

  /// Throws: [ServerException] if the API request fails.
  @override
  Future<bool> hasGmailScope() async {
    try {
      return await googleSignIn.canAccessScopes([
        'https://www.googleapis.com/auth/gmail.readonly',
      ]);
    } catch (e) {
      debugPrint(
        'AuthRemoteDatasource: Failed to check Gmail scope: ${e.runtimeType}',
      );

      return false;
    }
  }

  User _mapFirebaseUserToEntity(fb.User user) {
    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  /// Throws: [ServerException] if the API request fails.
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

  /// Throws: [ServerException] if the API request fails.
  Future<void> _obtainJwtToken(fb.User firebaseUser) async {
    final firebaseToken = await firebaseUser.getIdToken(true);
    final apiClient = di.getIt<ApiClient>();
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
