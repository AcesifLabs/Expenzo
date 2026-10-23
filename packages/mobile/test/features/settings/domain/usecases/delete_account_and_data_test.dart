import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/wipe_local_data.dart';
import 'package:expense_tracker/features/settings/domain/usecases/delete_account_and_data.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockWipeLocalData extends Mock implements WipeLocalData {}

void main() {
  late _MockAuthRepository auth;
  late _MockWipeLocalData wipe;
  late DeleteAccountAndData useCase;
  late List<String> calls;

  setUpAll(() => registerFallbackValue(NoParams()));

  setUp(() {
    auth = _MockAuthRepository();
    wipe = _MockWipeLocalData();
    calls = [];
    useCase = DeleteAccountAndData(authRepository: auth, wipeLocalData: wipe);

    when(
      () => auth.pauseSyncEngine(),
    ).thenAnswer((_) async => calls.add('pause'));
    when(
      () => auth.resumeSyncEngine(),
    ).thenAnswer((_) async => calls.add('resume'));
    when(() => auth.reauthenticate()).thenAnswer((_) async {
      calls.add('reauth');

      return const Right(unit);
    });
    when(() => auth.deleteServerAccount()).thenAnswer((_) async {
      calls.add('server');

      return const Right(unit);
    });
    when(() => wipe(any())).thenAnswer((_) async {
      calls.add('wipe');

      return const Right(unit);
    });
    when(() => auth.deleteAccount()).thenAnswer((_) async {
      calls.add('firebase');

      return const Right(unit);
    });
  });

  test('success runs every step in order, ending with resume', () async {
    final result = await useCase(NoParams());

    expect(result, const Right(unit));
    expect(calls, ['pause', 'reauth', 'server', 'wipe', 'firebase', 'resume']);
  });

  test('re-auth failure stops before the server and resumes sync', () async {
    const failure = AuthFailure(message: 'stale');
    when(() => auth.reauthenticate()).thenAnswer((_) async {
      calls.add('reauth');

      return const Left(failure);
    });

    final result = await useCase(NoParams());

    expect(result, const Left(failure));
    expect(calls, ['pause', 'reauth', 'resume']);
  });

  test('server failure stops before the wipe and resumes sync', () async {
    const failure = NetworkFailure(message: 'timeout');
    when(() => auth.deleteServerAccount()).thenAnswer((_) async {
      calls.add('server');

      return const Left(failure);
    });

    final result = await useCase(NoParams());

    expect(result, const Left(failure));
    expect(calls, ['pause', 'reauth', 'server', 'resume']);
  });

  test(
    'wipe failure still deletes the Firebase user and returns Right',
    () async {
      when(() => wipe(any())).thenAnswer((_) async {
        calls.add('wipe');

        return const Left(CacheFailure(message: 'locked'));
      });

      final result = await useCase(NoParams());

      expect(result, const Right(unit));
      expect(calls, [
        'pause',
        'reauth',
        'server',
        'wipe',
        'firebase',
        'resume',
      ]);
    },
  );

  test('Firebase delete failure still returns Right and resumes', () async {
    when(() => auth.deleteAccount()).thenThrow(Exception('firebase down'));

    final result = await useCase(NoParams());

    expect(result, const Right(unit));
    expect(calls, ['pause', 'reauth', 'server', 'wipe', 'resume']);
  });
}
