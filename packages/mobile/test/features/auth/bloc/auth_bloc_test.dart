import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/usecases/get_current_user.dart';
import 'package:expense_tracker/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:expense_tracker/features/auth/domain/usecases/sign_out.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignOut extends Mock implements SignOut {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetCurrentUser mockGetCurrentUser;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late MockAuthRepository mockAuthRepository;
  late AuthBloc bloc;

  final testUser = User(
    uid: 'user-1',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUpAll(() {
    registerFallbackValue(NoParams());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => null,
        );
  });

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUser();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.firstSyncNeeded,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAuthRepository.isSyncEnabled(),
    ).thenAnswer((_) async => true);
    bloc = AuthBloc(
      signInWithGoogle: mockSignInWithGoogle,
      signOut: mockSignOut,
      getCurrentUser: mockGetCurrentUser,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('AuthCheckRequested', () {
    test('emits [AuthLoading, Authenticated] when user is logged in', () async {
      when(
        () => mockGetCurrentUser(any()),
      ).thenAnswer((_) async => Right(testUser));
      when(
        () => mockAuthRepository.checkConflict(),
      ).thenAnswer((_) async => SyncConflictType.none);
      when(() => mockAuthRepository.startSyncEngine()).thenAnswer((_) async {});

      final expected = [
        isA<AuthLoading>(),
        isA<Authenticated>().having((s) => s.user.uid, 'uid', 'user-1'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const AuthCheckRequested());
    });

    test('emits [AuthLoading, Unauthenticated] when user is null', () async {
      when(
        () => mockGetCurrentUser(any()),
      ).thenAnswer((_) async => const Right(null));

      final expected = [isA<AuthLoading>(), isA<Unauthenticated>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const AuthCheckRequested());
    });
  });

  group('SignOutRequested', () {
    test('emits [AuthLoading, Unauthenticated] on success', () async {
      when(() => mockSignOut(any())).thenAnswer((_) async => const Right(unit));
      when(() => mockAuthRepository.stopSyncEngine()).thenAnswer((_) async {});

      final expected = [isA<AuthLoading>(), isA<Unauthenticated>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const SignOutRequested());
    });
  });

  group('Sync switch', () {
    void signedIn({required bool syncEnabled}) {
      when(
        () => mockGetCurrentUser(any()),
      ).thenAnswer((_) async => Right(testUser));
      when(
        () => mockAuthRepository.isSyncEnabled(),
      ).thenAnswer((_) async => syncEnabled);
      when(() => mockAuthRepository.startSyncEngine()).thenAnswer((_) async {});
    }

    test('signing in with Sync off skips the conflict check', () async {
      signedIn(syncEnabled: false);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([const AuthLoading(), Authenticated(testUser)]),
      );
      bloc.add(const AuthCheckRequested());
      await states;

      verifyNever(() => mockAuthRepository.checkConflict());
    });

    test('turning Sync on runs the conflict check', () async {
      signedIn(syncEnabled: false);
      bloc.add(const AuthCheckRequested());
      await pumpEventQueue();
      when(
        () => mockAuthRepository.isSyncEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => mockAuthRepository.checkConflict(),
      ).thenAnswer((_) async => SyncConflictType.conflict);

      bloc.add(const FirstSyncRequested());
      await pumpEventQueue();

      expect(bloc.state, AuthSyncConflictPending(testUser));
    });

    test('FirstSyncRequested does nothing when signed out', () async {
      bloc.add(const FirstSyncRequested());
      await pumpEventQueue();

      expect(bloc.state, const AuthInitial());
      verifyNever(() => mockAuthRepository.checkConflict());
    });

    test('the engine signal starts the first sync', () async {
      final signal = StreamController<void>.broadcast();
      addTearDown(signal.close);
      when(
        () => mockAuthRepository.firstSyncNeeded,
      ).thenAnswer((_) => signal.stream);
      final listening = AuthBloc(
        signInWithGoogle: mockSignInWithGoogle,
        signOut: mockSignOut,
        getCurrentUser: mockGetCurrentUser,
        authRepository: mockAuthRepository,
      );
      addTearDown(listening.close);
      signedIn(syncEnabled: false);
      listening.add(const AuthCheckRequested());
      await pumpEventQueue();
      when(
        () => mockAuthRepository.isSyncEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => mockAuthRepository.checkConflict(),
      ).thenAnswer((_) async => SyncConflictType.none);

      signal.add(null);
      await pumpEventQueue();

      verify(() => mockAuthRepository.checkConflict()).called(1);
      verify(() => mockAuthRepository.startSyncEngine()).called(2);
    });

    blocTest<AuthBloc, AuthState>(
      'a failed conflict check signs in but leaves sync stopped, so '
      'nothing merges without the user choosing',
      setUp: () {
        signedIn(syncEnabled: true);
        when(
          () => mockAuthRepository.checkConflict(),
        ).thenThrow(Exception('summary unreachable'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [isA<AuthLoading>(), Authenticated(testUser)],
      verify: (_) => verifyNever(() => mockAuthRepository.startSyncEngine()),
    );
  });
}
