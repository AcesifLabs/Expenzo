import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_local_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDatasource localDatasource;

  SearchRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<SearchResult>>> searchExpenses(
    SearchFilters filters,
  ) async {
    try {
      final results = await localDatasource.searchExpenses(filters);
      return Right(results);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
