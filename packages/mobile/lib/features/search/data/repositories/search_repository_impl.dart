import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_local_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDatasource localDatasource;

  SearchRepositoryImpl({required this.localDatasource});

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<SearchResult>>> searchRecords(
    SearchFilters filters,
  ) async {
    try {
      final results = await localDatasource.searchRecords(filters);

      return Right(results);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e, s) {
      appLogger.error('Search repository error', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }
}
