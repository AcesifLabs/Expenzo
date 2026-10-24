import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/cached.dart';
import '../entities/group_role.dart';
import '../entities/group_summary.dart';
import '../entities/invite_code.dart';
import '../entities/my_group.dart';

/// The signed-in user's Family Group (ADR 0008). Reads fall back to the
/// per-account cache when the server cannot be reached.
abstract class FamilyRepository {
  /// The last cached group, read without waiting; null when not in a group
  /// or nothing is cached. Budget screens, the Settings row and Delete all
  /// data read it.
  MyGroup? get cachedGroup;

  /// The last cached summary of [cachedGroup], read without waiting.
  GroupSummary? get cachedSummary;

  /// With [preferCache], a cached value is returned without a request.
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

  /// An Admin removing someone else. Leaving is [leaveGroup].
  Future<Either<Failure, Unit>> removeMember({
    required String groupId,
    required String userId,
  });

  Future<Either<Failure, Unit>> leaveGroup(String groupId);

  Future<Either<Failure, Unit>> deleteGroup(String groupId);
}
