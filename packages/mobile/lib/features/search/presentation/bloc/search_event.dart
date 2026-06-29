import 'package:equatable/equatable.dart';
import '../../domain/entities/search_filters.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SearchEvent();
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  @override
  List<Object?> get props => [query];

  const SearchQueryChanged(this.query);
}

class SearchFiltersChanged extends SearchEvent {
  final SearchFilters filters;

  @override
  List<Object?> get props => [filters];

  const SearchFiltersChanged(this.filters);
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}
