import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/usecases/search_records.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRecords searchRecords;
  SearchFilters _currentFilters = const SearchFilters();

  SearchBloc({required this.searchRecords}) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged, transformer: restartable());
    on<SearchFiltersChanged>(
      _onSearchFiltersChanged,
      transformer: restartable(),
    );
    on<ClearSearch>(_onClearSearch, transformer: concurrent());
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final updatedFilters = _currentFilters.copyWith(
      query: event.query,
      clearQuery: event.query.isEmpty,
    );

    await _performSearch(updatedFilters, emit);
  }

  Future<void> _onSearchFiltersChanged(
    SearchFiltersChanged event,
    Emitter<SearchState> emit,
  ) async {
    await _performSearch(event.filters, emit);
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    await _performSearch(const SearchFilters(), emit);
  }

  Future<void> _performSearch(
    SearchFilters filters,
    Emitter<SearchState> emit,
  ) async {
    _currentFilters = filters;

    if (filters.isEmpty) {
      emit(const SearchInitial());

      return;
    }

    emit(const SearchLoading());

    final result = await searchRecords(filters);

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (results) =>
          emit(SearchLoaded(results: results, query: filters.query ?? '')),
    );
  }
}
