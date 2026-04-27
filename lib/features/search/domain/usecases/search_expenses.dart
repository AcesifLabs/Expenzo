import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/search_filters.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchExpenses {
  final SearchRepository repository;

  SearchExpenses({required this.repository});

  Future<Either<Failure, List<SearchResult>>> call(SearchFilters filters) {
    return repository.searchExpenses(filters);
  }
}
