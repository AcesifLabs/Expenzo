import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/database/daos/user_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_datasource.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class _MockFirebaseUser extends Mock implements fb.User {}

class _MockUserDao extends Mock implements UserDao {}

class _MockGoogleAccount extends Mock implements GoogleSignInAccount {}

class _MockGoogleAuth extends Mock implements GoogleSignInAuthentication {}

class _MockUserCredential extends Mock implements fb.UserCredential {}

DioException _error(DioExceptionType type, {int? status}) => DioException(
  requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
  type: type,
  response: status == null
      ? null
      : Response(
          requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
          statusCode: status,
        ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockDio dio;
  late _MockGoogleSignIn googleSignIn;
  late _MockFirebaseAuth firebaseAuth;
  late _MockUserDao userDao;
  late AuthRemoteDatasourceImpl datasource;
  final secureStorageCalls = <String>[];

  setUpAll(() {
    registerFallbackValue(
      fb.GoogleAuthProvider.credential(accessToken: 'a', idToken: 'i'),
    );
    // TokenStorage uses FlutterSecureStorage, whose channel hangs in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async {
            secureStorageCalls.add(call.method);

            return null;
          },
        );
  });

  void stubSilentSignIn() {
    final account = _MockGoogleAccount();
    final auth = _MockGoogleAuth();
    when(() => auth.accessToken).thenReturn('access');
    when(() => auth.idToken).thenReturn('id');
    when(() => account.authentication).thenAnswer((_) async => auth);
    when(() => googleSignIn.signInSilently()).thenAnswer((_) async => account);
  }

  setUp(() {
    secureStorageCalls.clear();
    dio = _MockDio();
    googleSignIn = _MockGoogleSignIn();
    firebaseAuth = _MockFirebaseAuth();
    userDao = _MockUserDao();
    final apiClient = _MockApiClient();
    when(() => apiClient.dio).thenReturn(dio);
    datasource = AuthRemoteDatasourceImpl(
      googleSignIn: googleSignIn,
      firebaseAuth: firebaseAuth,
      userDao: userDao,
      apiClient: apiClient,
    );
  });

  group('deleteServerAccount', () {
    void deleteThrows(Object error) =>
        when(() => dio.delete<Object?>(any())).thenThrow(error);

    test('calls DELETE /auth/account', () async {
      when(() => dio.delete<Object?>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
          statusCode: 200,
        ),
      );

      await datasource.deleteServerAccount();

      verify(() => dio.delete<Object?>(ApiConstants.deleteAccount)).called(1);
      expect(secureStorageCalls, contains('deleteAll'));
    });

    test('404 is a ServerException, not "already deleted"', () {
      // A deleted user gets 401 from the JWT check; 404 is a wrong route.
      deleteThrows(_error(DioExceptionType.badResponse, status: 404));

      expect(datasource.deleteServerAccount(), throwsA(isA<ServerException>()));
    });

    test('401 throws AuthException', () {
      deleteThrows(_error(DioExceptionType.badResponse, status: 401));

      expect(datasource.deleteServerAccount(), throwsA(isA<AuthException>()));
    });

    test(
      'the deleted-user 401 means an earlier attempt already deleted it',
      () async {
        deleteThrows(
          DioException(
            requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
              statusCode: 401,
              data: {'message': ApiConstants.deletedUserMessage},
            ),
          ),
        );

        await datasource.deleteServerAccount();

        expect(secureStorageCalls, contains('deleteAll'));
      },
    );

    test('a connection error throws NetworkException', () {
      deleteThrows(_error(DioExceptionType.connectionError));

      expect(
        datasource.deleteServerAccount(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('500 throws ServerException with the status', () {
      deleteThrows(_error(DioExceptionType.badResponse, status: 500));

      expect(
        datasource.deleteServerAccount(),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'status', 500),
        ),
      );
    });
  });

  group('reauthenticate', () {
    test('throws RequiresRecentLoginException without a Firebase user', () {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      expect(
        datasource.reauthenticate(),
        throwsA(isA<RequiresRecentLoginException>()),
      );
      verifyNever(() => googleSignIn.signInSilently());
    });

    test('re-authenticates with the silent Google account', () async {
      final user = _MockFirebaseUser();
      when(() => firebaseAuth.currentUser).thenReturn(user);
      stubSilentSignIn();
      when(
        () => user.reauthenticateWithCredential(any()),
      ).thenAnswer((_) async => _MockUserCredential());

      await datasource.reauthenticate();

      verify(() => user.reauthenticateWithCredential(any())).called(1);
    });

    test('throws RequiresRecentLoginException without a silent account', () {
      when(() => firebaseAuth.currentUser).thenReturn(_MockFirebaseUser());
      when(() => googleSignIn.signInSilently()).thenAnswer((_) async => null);

      expect(
        datasource.reauthenticate(),
        throwsA(isA<RequiresRecentLoginException>()),
      );
    });
  });

  group('deleteAccount', () {
    late _MockFirebaseUser user;

    setUp(() {
      user = _MockFirebaseUser();
      when(() => firebaseAuth.currentUser).thenReturn(user);
      when(() => googleSignIn.signOut()).thenAnswer((_) async => null);
      when(() => userDao.clearUser()).thenAnswer((_) async {});
      when(() => firebaseAuth.signOut()).thenAnswer((_) async {});
    });

    void verifyCleanup() {
      verify(() => userDao.clearUser()).called(1);
      verify(() => googleSignIn.signOut()).called(1);
      verify(() => firebaseAuth.signOut()).called(1);
    }

    test('deletes the user and cleans up', () async {
      when(user.delete).thenAnswer((_) async {});

      await datasource.deleteAccount();

      verify(user.delete).called(1);
      verifyCleanup();
    });

    test('cleans up when the delete fails', () async {
      when(user.delete).thenThrow(fb.FirebaseAuthException(code: 'internal'));

      await expectLater(
        datasource.deleteAccount(),
        throwsA(isA<fb.FirebaseAuthException>()),
      );
      verifyCleanup();
    });

    test('requires-recent-login re-authenticates and retries', () async {
      var calls = 0;
      when(user.delete).thenAnswer((_) async {
        if (calls++ == 0) {
          throw fb.FirebaseAuthException(code: 'requires-recent-login');
        }
      });
      stubSilentSignIn();
      when(
        () => user.reauthenticateWithCredential(any()),
      ).thenAnswer((_) async => _MockUserCredential());

      await datasource.deleteAccount();

      verify(() => user.reauthenticateWithCredential(any())).called(1);
      verify(user.delete).called(2);
      verifyCleanup();
    });

    test('requires-recent-login without a silent account throws '
        'RequiresRecentLoginException and still cleans up', () async {
      when(
        user.delete,
      ).thenThrow(fb.FirebaseAuthException(code: 'requires-recent-login'));
      when(() => googleSignIn.signInSilently()).thenAnswer((_) async => null);

      await expectLater(
        datasource.deleteAccount(),
        throwsA(isA<RequiresRecentLoginException>()),
      );
      verifyCleanup();
    });

    test('a failing cleanup step does not skip the others', () async {
      when(user.delete).thenAnswer((_) async {});
      when(() => userDao.clearUser()).thenThrow(Exception('db locked'));

      await datasource.deleteAccount();

      verify(() => googleSignIn.signOut()).called(1);
      verify(() => firebaseAuth.signOut()).called(1);
    });

    test('cleans up even without a Firebase user', () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      await datasource.deleteAccount();

      verifyCleanup();
    });
  });
}
