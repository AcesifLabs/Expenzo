import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/invite_code.dart';
import '../repositories/family_repository.dart';
import 'get_group_summary.dart';

class CreateInvite extends UseCase<InviteCode, GroupIdParams> {
  final FamilyRepository repository;

  CreateInvite(this.repository);

  @override
  Future<Either<Failure, InviteCode>> call(GroupIdParams params) =>
      repository.createInvite(params.groupId);
}
