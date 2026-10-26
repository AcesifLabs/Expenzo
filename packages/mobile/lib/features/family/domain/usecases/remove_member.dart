import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../repositories/family_repository.dart';

class RemoveMemberParams extends Params {
  final String groupId;
  final String userId;

  @override
  List<Object?> get props => [groupId, userId];

  const RemoveMemberParams({required this.groupId, required this.userId});
}

class RemoveMember extends UseCase<Unit, RemoveMemberParams> {
  final FamilyRepository repository;

  RemoveMember(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RemoveMemberParams params) =>
      repository.removeMember(groupId: params.groupId, userId: params.userId);
}
