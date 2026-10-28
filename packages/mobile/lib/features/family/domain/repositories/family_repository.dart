import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/cached.dart';
import '../entities/group_role.dart';
import '../entities/group_summary.dart';
import '../entities/invite_code.dart';
import '../entities/my_group.dart';

abstract class FamilyRepository {
  MyGroup? get cachedGroup;

  GroupSummary? get cachedSummary;

  Future<Either<Failure, Cached<MyGroup?>>> getMyGroup({
    bool preferCache = false,
  });

  Future<Either<Failure, Cached<GroupSummary>>> getSummary(String groupId);

  Future<Either<Failure, MyGroup>> createGroup({
    required String name,
    required String currencyCode,
    double? monthlyBudget,
  });

  Future<Either<Failure, MyGroup>> joinGroup({
    required String code,
    required String currencyCode,
  });

  Future<Either<Failure, InviteCode>> createInvite(String groupId);

  Future<Either<Failure, MyGroup>> updateRole({
    required String groupId,
    required String userId,
    required GroupRole role,
  });

  Future<Either<Failure, Unit>> removeMember({
    required String groupId,
    required String userId,
  });

  Future<Either<Failure, Unit>> leaveGroup(String groupId);

  Future<Either<Failure, Unit>> deleteGroup(String groupId);
}
