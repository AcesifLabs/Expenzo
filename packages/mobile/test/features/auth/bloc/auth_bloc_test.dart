import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
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

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUser();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockAuthRepository = MockAuthRepository();
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
}
