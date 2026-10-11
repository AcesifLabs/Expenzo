import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class _MockRecordDao extends Mock implements RecordDao {}

class _MockLocalDatasource extends Mock implements RecordLocalDatasource {}

class _MockRemoteDatasource extends Mock implements RecordRemoteDatasource {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  setUpAll(() {
    // The datasource logs the DAO error these tests provoke.
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  });

  group('RecordLocalDatasourceImpl.getCategoryRecordCounts', () {
    late _MockRecordDao dao;
    late RecordLocalDatasourceImpl datasource;

    setUp(() {
      dao = _MockRecordDao();
      datasource = RecordLocalDatasourceImpl(recordDao: dao);
    });

    test('returns the DAO map', () async {
      when(
        () => dao.getCategoryRecordCounts(),
      ).thenAnswer((_) async => {'cat-1': 3});

      expect(await datasource.getCategoryRecordCounts(), {'cat-1': 3});
    });

    test('rethrows a DAO error as CacheException', () async {
      when(() => dao.getCategoryRecordCounts()).thenThrow(StateError('db'));

      await expectLater(
        datasource.getCategoryRecordCounts(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('RecordRepositoryImpl.getCategoryRecordCounts', () {
    late _MockLocalDatasource local;
    late RecordRepositoryImpl repository;

    setUp(() {
      local = _MockLocalDatasource();
      repository = RecordRepositoryImpl(
        localDatasource: local,
        remoteDatasource: _MockRemoteDatasource(),
        connectivity: _MockConnectivityService(),
      );
    });

    test('returns the datasource map as Right', () async {
      when(
        () => local.getCategoryRecordCounts(),
      ).thenAnswer((_) async => {'cat-1': 3});

      final result = await repository.getCategoryRecordCounts();

      expect(result.fold((_) => null, (counts) => counts), {'cat-1': 3});
    });

    test('maps a CacheException to Left(CacheFailure)', () async {
      when(
        () => local.getCategoryRecordCounts(),
      ).thenThrow(CacheException(message: 'db'));

      final result = await repository.getCategoryRecordCounts();

      expect(result, isA<Left<CacheFailure, Map<String, int>>>());
    });

    test('maps any other error to Left(CacheFailure)', () async {
      when(() => local.getCategoryRecordCounts()).thenThrow(StateError('db'));

      // The repository debugPrints the unexpected error; keep output clean.
      final originalDebugPrint = debugPrint;
      debugPrint = (_, {wrapWidth}) {};
      final Either<CacheFailure, Map<String, int>> result;
      try {
        result = await repository.getCategoryRecordCounts();
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(
        result.fold((failure) => failure, (_) => null),
        isA<CacheFailure>(),
      );
    });
  });
}
