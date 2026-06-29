import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];

  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  final String query;

  @override
  List<Object?> get props => [results, query];

  const SearchLoaded({required this.results, required this.query});
}

class SearchError extends SearchState {
  final String message;

  @override
  List<Object?> get props => [message];

  const SearchError(this.message);
}
