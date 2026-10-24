import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/cached.dart';
import '../entities/group_summary.dart';
import '../repositories/family_repository.dart';

class GroupIdParams extends Params {
  final String groupId;

  @override
  List<Object?> get props => [groupId];

  const GroupIdParams(this.groupId);
}

class GetGroupSummary extends UseCase<Cached<GroupSummary>, GroupIdParams> {
  final FamilyRepository repository;

  GetGroupSummary(this.repository);

  @override
  Future<Either<Failure, Cached<GroupSummary>>> call(GroupIdParams params) =>
      repository.getSummary(params.groupId);
}
