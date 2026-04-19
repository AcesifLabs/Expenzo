import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/usecases/search_expenses.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchExpenses searchExpenses;
  final SearchFilters _currentFilters = const SearchFilters();
  Timer? _debounceTimer;

  SearchBloc({required this.searchExpenses}) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchFiltersChanged>(_onSearchFiltersChanged);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();

    final updatedFilters = _currentFilters.copyWith(
      query: event.query,
      clearQuery: event.query.isEmpty,
    );

    if (event.query.isEmpty) {
      await _performSearch(updatedFilters, emit);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performSearch(updatedFilters, emit);
    });
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
    _debounceTimer?.cancel();
    await _performSearch(const SearchFilters(), emit);
  }

  Future<void> _performSearch(
    SearchFilters filters,
    Emitter<SearchState> emit,
  ) async {
    if (filters.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    final result = await searchExpenses(filters);

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (results) =>
          emit(SearchLoaded(results: results, query: filters.query ?? '')),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
