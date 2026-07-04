import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/search_filters.dart';
import '../entities/search_result.dart';

/// Repository for searching records.
abstract class SearchRepository {
  /// Searches records matching the given [filters].
  ///
  /// Returns [Right(List<SearchResult>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<SearchResult>>> searchRecords(
    SearchFilters filters,
  );
}
