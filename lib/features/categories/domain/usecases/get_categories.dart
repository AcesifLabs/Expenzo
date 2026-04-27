import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories extends UseCase<List<Category>, GetCategoriesParams> {
  final CategoryRepository repository;

  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(GetCategoriesParams params) {
    return repository.getCategories(type: params.type);
  }
}

class GetCategoriesParams extends Params {
  final RecordType? type;
  const GetCategoriesParams({this.type});

  @override
  List<Object?> get props => [type];
}
