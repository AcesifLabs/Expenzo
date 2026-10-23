import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';

class _MockRemote extends Mock implements AuthRemoteDatasource {}

class _MockSyncEngine extends Mock implements SyncEngine {}

void main() {
  late _MockRemote remote;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = AuthRepositoryImpl(remoteDatasource: remote);
  });

  group('deleteServerAccount', () {
    test('success is Right', () async {
      when(() => remote.deleteServerAccount()).thenAnswer((_) async {});

      expect(await repository.deleteServerAccount(), const Right(unit));
    });

    test('offline is a NetworkFailure', () async {
      when(
        () => remote.deleteServerAccount(),
      ).thenThrow(const NetworkException(message: 'offline'));

      final result = await repository.deleteServerAccount();

      expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
    });

    test('500 is a ServerFailure', () async {
      when(
        () => remote.deleteServerAccount(),
      ).thenThrow(const ServerException(message: 'boom', statusCode: 500));

      final result = await repository.deleteServerAccount();

      expect(result.fold((f) => f, (_) => null), isA<ServerFailure>());
    });

    test('401 is an AuthFailure', () async {
      when(
        () => remote.deleteServerAccount(),
      ).thenThrow(const AuthException(message: 'expired'));

      final result = await repository.deleteServerAccount();

      expect(result.fold((f) => f, (_) => null), isA<AuthFailure>());
    });
  });

  test('re-auth needing a prompt is an AuthFailure with the '
      'requiresRecentLogin code', () async {
    when(() => remote.reauthenticate()).thenThrow(
      const RequiresRecentLoginException(message: 'no silent account'),
    );

    final result = await repository.reauthenticate();
    final failure = result.fold((f) => f, (_) => null);

    expect(failure, isA<AuthFailure>());
    expect(failure?.errorCode, FailureCodes.requiresRecentLogin);
  });

  test('deleteAccount maps RequiresRecentLoginException to its code', () async {
    when(
      () => remote.deleteAccount(),
    ).thenThrow(const RequiresRecentLoginException(message: 'stale sign-in'));

    final result = await repository.deleteAccount();

    expect(
      result.fold((f) => f.errorCode, (_) => null),
      FailureCodes.requiresRecentLogin,
    );
  });

  group('pause and resume sync', () {
    late _MockSyncEngine engine;

    setUp(() {
      engine = _MockSyncEngine();
      GetIt.instance.registerSingleton<SyncEngine>(engine);
    });

    tearDown(() => GetIt.instance.unregister<SyncEngine>());

    test('delegate to the sync engine', () async {
      when(() => engine.pause()).thenAnswer((_) async {});
      when(() => engine.resume()).thenAnswer((_) async {});

      await repository.pauseSyncEngine();
      await repository.resumeSyncEngine();

      verify(() => engine.pause()).called(1);
      verify(() => engine.resume()).called(1);
    });

    test('never throw, so the delete flow keeps going', () async {
      when(() => engine.pause()).thenThrow(StateError('stopped'));
      when(() => engine.resume()).thenThrow(StateError('stopped'));

      await expectLater(repository.pauseSyncEngine(), completes);
      await expectLater(repository.resumeSyncEngine(), completes);
    });
  });
}
