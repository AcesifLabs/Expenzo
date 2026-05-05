import 'package:equatable/equatable.dart';
import '../../domain/entities/search_filters.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchFiltersChanged extends SearchEvent {
  final SearchFilters filters;

  const SearchFiltersChanged(this.filters);

  @override
  List<Object?> get props => [filters];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}
