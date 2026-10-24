import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/group_role.dart';
import '../entities/my_group.dart';
import '../repositories/family_repository.dart';

class UpdateMemberRoleParams extends Params {
  final String groupId;
  final String userId;
  final GroupRole role;

  @override
  List<Object?> get props => [groupId, userId, role];

  const UpdateMemberRoleParams({
    required this.groupId,
    required this.userId,
    required this.role,
  });
}

class UpdateMemberRole extends UseCase<MyGroup, UpdateMemberRoleParams> {
  final FamilyRepository repository;

  UpdateMemberRole(this.repository);

  @override
  Future<Either<Failure, MyGroup>> call(UpdateMemberRoleParams params) =>
      repository.updateRole(
        groupId: params.groupId,
        userId: params.userId,
        role: params.role,
      );
}
