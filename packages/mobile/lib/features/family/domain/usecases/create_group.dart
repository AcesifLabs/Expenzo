import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/my_group.dart';
import '../repositories/family_repository.dart';

class CreateGroupParams extends Params {
  final String name;

  final String currencyCode;
  final double? monthlyBudget;

  @override
  List<Object?> get props => [name, currencyCode, monthlyBudget];

  const CreateGroupParams({
    required this.name,
    required this.currencyCode,
    this.monthlyBudget,
  });
}

class CreateGroup extends UseCase<MyGroup, CreateGroupParams> {
  final FamilyRepository repository;

  CreateGroup(this.repository);

  @override
  Future<Either<Failure, MyGroup>> call(CreateGroupParams params) =>
      repository.createGroup(
        name: params.name,
        currencyCode: params.currencyCode,
        monthlyBudget: params.monthlyBudget,
      );
}
