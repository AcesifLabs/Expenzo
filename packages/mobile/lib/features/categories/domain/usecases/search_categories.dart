import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class SearchCategories extends UseCase<List<Category>, SearchCategoriesParams> {
  final CategoryRepository repository;

  SearchCategories(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, List<Category>>> call(SearchCategoriesParams params) {
    return repository.searchCategories(query: params.query, type: params.type);
  }
}

class SearchCategoriesParams extends Params {
  final String query;
  final RecordType? type;

  @override
  List<Object?> get props => [query, type];

  const SearchCategoriesParams({required this.query, this.type});
}
