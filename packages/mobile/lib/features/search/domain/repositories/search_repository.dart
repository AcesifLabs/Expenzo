import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/search_filters.dart';
import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchResult>>> searchRecords(
    SearchFilters filters,
  );
}
