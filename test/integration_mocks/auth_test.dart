import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:expense_tracker/features/auth/domain/usecases/sign_out.dart';
import 'package:expense_tracker/features/auth/domain/usecases/get_current_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('Auth Use Case Tests', () {
    late MockAuthRepository mockRepository;
    late SignInWithGoogle signInWithGoogleUseCase;
    late SignOut signOutUseCase;
    late GetCurrentUser getCurrentUserUseCase;

    final testUser = User(
      uid: 'test_uid_123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
    );

    setUp(() {
      mockRepository = MockAuthRepository();
      signInWithGoogleUseCase = SignInWithGoogle(mockRepository);
      signOutUseCase = SignOut(mockRepository);
      getCurrentUserUseCase = GetCurrentUser(mockRepository);
    });

    test('getCurrentUser returns user when signed in', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => Right(testUser));

      final result = await getCurrentUserUseCase(NoParams());

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (user) {
        expect(user, testUser);
        expect(user?.uid, 'test_uid_123');
      });
    });

    test('getCurrentUser returns null when not signed in', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(null));

      final result = await getCurrentUserUseCase(NoParams());

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) => expect(user, null),
      );
    });

    test('signInWithGoogle returns user on success', () async {
      when(
        () => mockRepository.signInWithGoogle(),
      ).thenAnswer((_) async => Right(testUser));

      final result = await signInWithGoogleUseCase(NoParams());

      expect(result.isRight(), true);
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('signOut returns unit on success', () async {
      when(
        () => mockRepository.signOut(),
      ).thenAnswer((_) async => const Right(unit));

      final result = await signOutUseCase(NoParams());

      expect(result.isRight(), true);
      verify(() => mockRepository.signOut()).called(1);
    });

    test('hasGmailScope returns false when scope not granted', () async {
      when(
        () => mockRepository.hasGmailScope(),
      ).thenAnswer((_) async => const Right(false));

      final result = await mockRepository.hasGmailScope();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (hasScope) => expect(hasScope, false),
      );
    });
  });

  group('User Entity Tests', () {
    test('should create user with required fields', () {
      const user = User(uid: 'test_uid');

      expect(user.uid, 'test_uid');
      expect(user.email, null);
      expect(user.displayName, null);
      expect(user.photoUrl, null);
    });

    test('should create user with all fields', () {
      final user = User(
        uid: 'test_uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
      );

      expect(user.uid, 'test_uid');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
    });

    test('should copy user with updated fields', () {
      final original = User(
        uid: 'test_uid',
        email: 'old@example.com',
        displayName: 'Old Name',
      );

      final updated = original.copyWith(email: 'new@example.com');

      expect(updated.uid, 'test_uid');
      expect(updated.email, 'new@example.com');
      expect(updated.displayName, 'Old Name');
    });
  });
}
