import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/search/domain/entities/search_filters.dart';
import 'package:expense_tracker/features/search/domain/entities/search_result.dart';
import 'package:expense_tracker/features/search/domain/usecases/search_records.dart';
import 'package:expense_tracker/features/search/presentation/bloc/search_bloc.dart';
import 'package:expense_tracker/features/search/presentation/bloc/search_event.dart';
import 'package:expense_tracker/features/search/presentation/bloc/search_state.dart';

class MockSearchRecords extends Mock implements SearchRecords {}

class _SearchFiltersFake extends Fake implements SearchFilters {}

void main() {
  setUpAll(() {
    registerFallbackValue(_SearchFiltersFake());
  });
  late MockSearchRecords mockSearchRecords;
  late SearchBloc bloc;

  setUp(() {
    mockSearchRecords = MockSearchRecords();
    bloc = SearchBloc(searchRecords: mockSearchRecords);
  });

  tearDown(() {
    bloc.close();
  });

  group('SearchQueryChanged', () {
    test('emits [SearchInitial] for empty query', () async {
      final expected = [isA<SearchInitial>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const SearchQueryChanged(''));
    });

    test('emits [SearchLoading, SearchLoaded] on success', () async {
      final result = SearchResult(
        recordId: 'rec-1',
        description: 'Groceries',
        amount: 50.0,
        date: DateTime.now(),
      );

      when(
        () => mockSearchRecords(any()),
      ).thenAnswer((_) async => Right([result]));

      final expected = [
        isA<SearchLoading>(),
        isA<SearchLoaded>().having(
          (s) => s.results.length,
          'results length',
          1,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const SearchQueryChanged('groceries'));
    });

    test('emits [SearchLoading, SearchError] on failure', () async {
      when(
        () => mockSearchRecords(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Search failed')));

      final expected = [
        isA<SearchLoading>(),
        isA<SearchError>().having((s) => s.message, 'message', 'Search failed'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const SearchQueryChanged('groceries'));
    });
  });
}
