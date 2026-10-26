import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../repositories/family_repository.dart';
import 'get_group_summary.dart';

class DeleteGroup extends UseCase<Unit, GroupIdParams> {
  final FamilyRepository repository;

  DeleteGroup(this.repository);

  @override
  Future<Either<Failure, Unit>> call(GroupIdParams params) =>
      repository.deleteGroup(params.groupId);
}
