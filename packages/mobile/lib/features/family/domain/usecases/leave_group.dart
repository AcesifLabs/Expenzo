import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../repositories/family_repository.dart';
import 'get_group_summary.dart';

class LeaveGroup extends UseCase<Unit, GroupIdParams> {
  final FamilyRepository repository;

  LeaveGroup(this.repository);

  @override
  Future<Either<Failure, Unit>> call(GroupIdParams params) =>
      repository.leaveGroup(params.groupId);
}
