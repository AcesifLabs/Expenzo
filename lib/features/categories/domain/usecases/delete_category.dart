import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../../../../core/error/exceptions.dart';
import '../repositories/category_repository.dart';

class DeleteCategory extends UseCase<Unit, int> {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int id) async {
    try {
      return await repository.deleteCategory(id);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }
}
