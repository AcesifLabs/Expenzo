import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  AuthRemoteDatasourceImpl({
    required this.googleSignIn,
    required this.firebaseAuth,
  });

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

    return _mapFirebaseUserToEntity(firebaseUser);
  }

  @override
  Future<void> signOut() async {
    debugPrint('AuthRemoteDatasource: signOut called');
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    debugPrint('AuthRemoteDatasource: getCurrentUser called');
    final firebaseUser = firebaseAuth.currentUser;
    debugPrint('AuthRemoteDatasource: currentUser: $firebaseUser');
    if (firebaseUser == null) return null;
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
}
