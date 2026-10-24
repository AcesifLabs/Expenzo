import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/my_group.dart';
import '../repositories/family_repository.dart';

class JoinGroupParams extends Params {
  final String code;
  final String currencyCode;

  @override
  List<Object?> get props => [code, currencyCode];

  const JoinGroupParams({required this.code, required this.currencyCode});
}

class JoinGroup extends UseCase<MyGroup, JoinGroupParams> {
  final FamilyRepository repository;

  JoinGroup(this.repository);

  @override
  Future<Either<Failure, MyGroup>> call(JoinGroupParams params) => repository
      .joinGroup(code: params.code, currencyCode: params.currencyCode);
}
