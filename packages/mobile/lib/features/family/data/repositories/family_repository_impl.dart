import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../../domain/entities/cached.dart';
import '../../domain/entities/group_role.dart';
import '../../domain/entities/group_summary.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/entities/my_group.dart';
import '../../domain/repositories/family_repository.dart';
import '../datasources/family_local_datasource.dart';
import '../datasources/family_remote_datasource.dart';

typedef GroupFetchedHook =
    Future<void> Function({MyGroup? previous, MyGroup? current});

class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyRemoteDatasource remote;
  final FamilyLocalDatasource local;
  final GroupFetchedHook onGroupFetched;
  final DateTime Function() clock;

  static const _familyCodes = {
    FailureCodes.alreadyInGroup,
    FailureCodes.currencyMismatch,
    FailureCodes.groupFull,
    FailureCodes.inviteExpired,
    FailureCodes.inviteNotFound,
    FailureCodes.lastAdmin,
    FailureCodes.notInGroup,
  };

  @override
  MyGroup? get cachedGroup => local.readGroup()?.value;

  @override
  GroupSummary? get cachedSummary =>
      cachedGroup == null ? null : local.readSummary()?.value;

  FamilyRepositoryImpl({
    required this.remote,
    required this.local,
    required this.onGroupFetched,
    this.clock = DateTime.now,
  });

  @override
  Future<Either<Failure, Cached<MyGroup?>>> getMyGroup({
    bool preferCache = false,
  }) async {
    final fallback = local.readGroup()?.asFromCache();
    if (preferCache && fallback != null) return Right(fallback);
    try {
      final group = await remote.getMyGroup();
      final now = clock();
      await _saveGroup(group, now);

      return Right(Cached(group, fetchedAt: now));
    } on ServerException catch (e) {
      if (fallback != null && _canUseCache(e)) return Right(fallback);

      return Left(_failureFor(e));
    }
  }

  @override
  Future<Either<Failure, Cached<GroupSummary>>> getSummary(
    String groupId,
  ) async {
    try {
      final summary = await remote.getSummary(
        groupId,
        utcOffsetMinutes: clock().timeZoneOffset.inMinutes,
      );
      final now = clock();
      await local.writeSummary(summary, now);

      return Right(Cached(summary, fetchedAt: now));
    } on ServerException catch (e) {
      if (_isNotInGroup(e)) await _saveGroup(null, clock());
      final fallback = _cachedSummaryOf(groupId)?.asFromCache();
      if (fallback != null && _canUseCache(e)) return Right(fallback);

      return Left(_failureFor(e));
    }
  }

  @override
  Future<Either<Failure, MyGroup>> createGroup({
    required String name,
    required String currencyCode,
    double? monthlyBudget,
  }) => _savingGroup(
    () => remote.createGroup(
      name: name,
      currencyCode: currencyCode,
      monthlyBudget: monthlyBudget,
    ),
  );

  @override
  Future<Either<Failure, MyGroup>> joinGroup({
    required String code,
    required String currencyCode,
  }) => _savingGroup(
    () => remote.joinGroup(code: code, currencyCode: currencyCode),
  );

  @override
  Future<Either<Failure, MyGroup>> updateRole({
    required String groupId,
    required String userId,
    required GroupRole role,
  }) => _savingGroup(
    () => remote.updateRole(groupId: groupId, userId: userId, role: role),
  );

  @override
  Future<Either<Failure, InviteCode>> createInvite(String groupId) =>
      _request(() async {
        final invite = await remote.createInvite(groupId);

        final cached = local.readGroup();
        if (cached case Cached(value: final group?, :final fetchedAt)) {
          await local.writeGroup(group.copyWith(invite: invite), fetchedAt);
        }

        return invite;
      });

  @override
  Future<Either<Failure, Unit>> removeMember({
    required String groupId,
    required String userId,
  }) => _request(() async {
    await remote.removeMember(groupId: groupId, userId: userId);

    return unit;
  });

  @override
  Future<Either<Failure, Unit>> leaveGroup(String groupId) async {
    final myUserId = cachedGroup?.myUserId;
    if (myUserId == null) {
      return const Left(
        ServerFailure(
          message: 'No cached group to leave',
          errorCode: FailureCodes.notInGroup,
        ),
      );
    }

    return _request(() async {
      await remote.removeMember(groupId: groupId, userId: myUserId);
      await _saveGroup(null, clock());

      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteGroup(String groupId) =>
      _request(() async {
        await remote.deleteGroup(groupId);
        await _saveGroup(null, clock());

        return unit;
      });

  Future<Either<Failure, MyGroup>> _savingGroup(
    Future<MyGroup> Function() call,
  ) => _request(() async {
    final group = await call();
    await _saveGroup(group, clock());

    return group;
  });

  Future<Either<Failure, T>> _request<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ServerException catch (e) {
      if (_isNotInGroup(e)) await _saveGroup(null, clock());

      return Left(_failureFor(e));
    }
  }

  Future<void> _saveGroup(MyGroup? group, DateTime fetchedAt) async {
    final previous = local.readGroup()?.value;
    await local.writeGroup(group, fetchedAt);
    if (group == null || group.group.id != previous?.group.id) {
      await local.clearSummary();
    }
    await onGroupFetched(previous: previous, current: group);
  }

  Cached<GroupSummary>? _cachedSummaryOf(String groupId) {
    final group = cachedGroup;
    final summary = local.readSummary();
    if (group == null || group.group.id != groupId) {
      local.clearSummary();

      return null;
    }

    return summary?.value.groupId == groupId ? summary : null;
  }

  bool _canUseCache(ServerException e) {
    final status = e.statusCode;

    return status == null || status >= 500;
  }

  bool _isNotInGroup(ServerException e) =>
      e.statusCode == 404 && e.message == FailureCodes.notInGroup;

  Failure _failureFor(ServerException e) {
    final status = e.statusCode;
    if (status == null) return NetworkFailure(message: e.message);
    if (status == 401) return AuthFailure(message: e.message);

    return ServerFailure(
      message: e.message,
      errorCode: _familyCodes.contains(e.message) ? e.message : 'SERVER_ERROR',
      statusCode: status,
    );
  }
}
