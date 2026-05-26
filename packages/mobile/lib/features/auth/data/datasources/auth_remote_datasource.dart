import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/database/app_database.dart' show UsersCompanion;
import '../../../../core/database/daos/user_dao.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/api/token_storage.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDatasource {
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Future<bool> isSignedIn();
  Future<void> deleteAccount();
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

  @visibleForTesting
  static bool isDevTokenFallbackAllowed({required bool isDebugMode}) {
    return isDebugMode;
  }

  @override
  Future<User> signInWithGoogle() async {
    debugPrint('AuthRemoteDatasource: signInWithGoogle started');

    // Check existing Google account
    final googleAccount = await googleSignIn.signInSilently();
    debugPrint('AuthRemoteDatasource: signInSilently result: $googleAccount');

    final googleUser = await googleSignIn.signIn();
    debugPrint('AuthRemoteDatasource: signIn result: $googleUser');

    if (googleUser == null) {
      debugPrint('AuthRemoteDatasource: Google sign in was cancelled by user');
      throw Exception('Google sign in was cancelled');
    }

    final googleAuth = await googleUser.authentication;
    debugPrint('AuthRemoteDatasource: Got google auth tokens');

    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    debugPrint('AuthRemoteDatasource: Calling Firebase signInWithCredential');
    final userCredential = await firebaseAuth.signInWithCredential(credential);
    debugPrint('AuthRemoteDatasource: Firebase signInWithCredential succeeded');

    final firebaseUser = userCredential.user;
    debugPrint('AuthRemoteDatasource: Firebase user: $firebaseUser');

    if (firebaseUser == null) {
      throw Exception('Firebase sign in failed');
    }

    final user = _mapFirebaseUserToEntity(firebaseUser);
    await _syncUserToLocalDb(firebaseUser);

    // Get backend JWT
    try {
      final firebaseToken = await firebaseUser.getIdToken(true);
      final apiClient = di.getIt<ApiClient>();
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {'firebaseToken': firebaseToken},
      );
      await TokenStorage.saveToken(response.data['accessToken']);
      debugPrint('AuthRemoteDatasource: Backend JWT obtained');
    } catch (e) {
      debugPrint('AuthRemoteDatasource: Backend JWT with Firebase failed: $e');

      if (!isDevTokenFallbackAllowed(isDebugMode: kDebugMode)) {
        rethrow;
      }

      try {
        final payload = {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'name': firebaseUser.displayName,
        };
        final devToken =
            'dev-${base64Encode(const Utf8Encoder().convert(jsonEncode(payload)))}';
        final response = await di.getIt<ApiClient>().dio.post(
          ApiConstants.login,
          data: {'firebaseToken': devToken},
        );
        await TokenStorage.saveToken(response.data['accessToken']);
        debugPrint('AuthRemoteDatasource: Dev JWT obtained');
      } catch (e2) {
        debugPrint('AuthRemoteDatasource: Dev JWT also failed: $e2');
        rethrow;
      }
    }

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
    debugPrint('AuthRemoteDatasource: getCurrentUser called');
    final firebaseUser = firebaseAuth.currentUser;
    debugPrint('AuthRemoteDatasource: currentUser: $firebaseUser');
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
  Future<void> deleteAccount() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      await user.delete();
      await userDao.clearUser();
    }
  }

  @override
  Future<bool> hasGmailScope() async {
    try {
      return await googleSignIn.canAccessScopes([
        'https://www.googleapis.com/auth/gmail.readonly',
      ]);
    } catch (e) {
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

  Future<void> _syncUserToLocalDb(fb.User firebaseUser) async {
    try {
      final now = DateTime.now().toUtc();
      await userDao.upsertUser(
        UsersCompanion.insert(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: Value(firebaseUser.displayName),
          photoUrl: Value(firebaseUser.photoURL),
          createdAt: now,
          lastLoginAt: now,
        ),
      );
    } catch (e) {
      debugPrint('AuthRemoteDatasource: Failed to sync user to local DB: $e');
      // Non-fatal: user is already authenticated at Firebase level
    }
  }
}
