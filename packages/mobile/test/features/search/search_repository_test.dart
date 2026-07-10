import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:talker/talker.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/search/data/datasources/search_local_datasource.dart';
import 'package:expense_tracker/features/search/data/repositories/search_repository_impl.dart';
import 'package:expense_tracker/features/search/domain/entities/search_filters.dart';
import 'package:expense_tracker/features/search/domain/entities/search_result.dart';

class MockSearchLocalDatasource extends Mock implements SearchLocalDatasource {}

class _SearchFiltersFake extends Fake implements SearchFilters {}

void main() {
  late MockSearchLocalDatasource mockDatasource;
  late SearchRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_SearchFiltersFake());
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  });

  setUp(() {
    mockDatasource = MockSearchLocalDatasource();
    repository = SearchRepositoryImpl(localDatasource: mockDatasource);
  });

  group('SearchRepositoryImpl', () {
    group('searchRecords', () {
      test('returns Right(results) on success', () async {
        final filters = const SearchFilters(query: 'test');
        final results = [
          SearchResult(
            recordId: 'rec-1',
            description: 'Test expense',
            amount: 50.0,
            date: DateTime(2024, 6, 15),
          ),
        ];
        when(
          () => mockDatasource.searchRecords(filters),
        ).thenAnswer((_) async => results);

        final result = await repository.searchRecords(filters);

        expect(result, Right(results));
        verify(() => mockDatasource.searchRecords(filters)).called(1);
      });

      test('returns Left(CacheFailure) on CacheException', () async {
        final filters = const SearchFilters(query: 'test');
        when(
          () => mockDatasource.searchRecords(filters),
        ).thenThrow(const CacheException(message: 'Search failed'));

        final result = await repository.searchRecords(filters);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, 'Search failed'),
          (_) => fail('Should not return Right'),
        );
      });

      test('returns Left(CacheFailure) on generic exception', () async {
        final filters = const SearchFilters(query: 'test');
        when(
          () => mockDatasource.searchRecords(filters),
        ).thenThrow(Exception('Unexpected error'));

        final result = await repository.searchRecords(filters);

        expect(result.isLeft(), true);
      });
    });
  });
}
