import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories extends UseCase<List<Category>, GetCategoriesParams> {
  final CategoryRepository repository;

  GetCategories(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, List<Category>>> call(GetCategoriesParams params) {
    return repository.getCategories(
      type: params.type,
      sortByUsage: params.sortByUsage,
    );
  }
}

class GetCategoriesParams extends Params {
  final RecordType? type;
  final bool sortByUsage;

  @override
  List<Object?> get props => [type, sortByUsage];

  const GetCategoriesParams({this.type, this.sortByUsage = false});
}
