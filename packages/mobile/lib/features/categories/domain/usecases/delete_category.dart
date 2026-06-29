import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import '../repositories/category_repository.dart';

class DeleteCategory extends UseCase<Unit, String> {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Unit>> call(String id) async {
    try {
      return await repository.deleteCategory(id);
    } on CacheException catch (e, s) {
      return Left(e.toFailure());
    }
  }
}
