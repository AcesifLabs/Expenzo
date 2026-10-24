import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/family/domain/entities/cached.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/invite_code.dart';
import 'package:expense_tracker/features/family/domain/repositories/family_repository.dart';
import 'package:expense_tracker/features/family/domain/usecases/create_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/create_invite.dart';
import 'package:expense_tracker/features/family/domain/usecases/delete_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/get_group_summary.dart';
import 'package:expense_tracker/features/family/domain/usecases/get_my_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/join_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/leave_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/remove_member.dart';
import 'package:expense_tracker/features/family/domain/usecases/update_member_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/factories/family_factory.dart';

class _MockRepository extends Mock implements FamilyRepository {}

void main() {
  late _MockRepository repository;
  final at = DateTime.utc(2026);
  final group = makeMyGroup();

  setUp(() => repository = _MockRepository());

  test('GetMyGroup forwards preferCache', () async {
    when(
      () => repository.getMyGroup(preferCache: true),
    ).thenAnswer((_) async => Right(Cached(group, fetchedAt: at)));

    await GetMyGroup(repository)(const GetMyGroupParams(preferCache: true));

    verify(() => repository.getMyGroup(preferCache: true)).called(1);
  });

  test('GetGroupSummary forwards the group id', () async {
    when(
      () => repository.getSummary('group-1'),
    ).thenAnswer((_) async => Right(Cached(makeGroupSummary(), fetchedAt: at)));

    await GetGroupSummary(repository)(const GroupIdParams('group-1'));

    verify(() => repository.getSummary('group-1')).called(1);
  });

  test('CreateGroup forwards name, currency and budget', () async {
    when(
      () => repository.createGroup(
        name: 'F',
        currencyCode: 'BDT',
        monthlyBudget: 10,
      ),
    ).thenAnswer((_) async => Right(group));

    await CreateGroup(repository)(
      const CreateGroupParams(
        name: 'F',
        currencyCode: 'BDT',
        monthlyBudget: 10,
      ),
    );

    verify(
      () => repository.createGroup(
        name: 'F',
        currencyCode: 'BDT',
        monthlyBudget: 10,
      ),
    ).called(1);
  });

  test('JoinGroup forwards code and currency', () async {
    when(
      () => repository.joinGroup(code: 'RF4XK2', currencyCode: 'BDT'),
    ).thenAnswer((_) async => Right(group));

    await JoinGroup(repository)(
      const JoinGroupParams(code: 'RF4XK2', currencyCode: 'BDT'),
    );

    verify(
      () => repository.joinGroup(code: 'RF4XK2', currencyCode: 'BDT'),
    ).called(1);
  });

  test(
    'CreateInvite, LeaveGroup and DeleteGroup forward the group id',
    () async {
      when(
        () => repository.createInvite('group-1'),
      ).thenAnswer((_) async => Right(InviteCode(code: 'A', expiresAt: at)));
      when(
        () => repository.leaveGroup('group-1'),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => repository.deleteGroup('group-1'),
      ).thenAnswer((_) async => const Right(unit));

      await CreateInvite(repository)(const GroupIdParams('group-1'));
      await LeaveGroup(repository)(const GroupIdParams('group-1'));
      await DeleteGroup(repository)(const GroupIdParams('group-1'));

      verify(() => repository.createInvite('group-1')).called(1);
      verify(() => repository.leaveGroup('group-1')).called(1);
      verify(() => repository.deleteGroup('group-1')).called(1);
    },
  );

  test('UpdateMemberRole and RemoveMember forward their params', () async {
    when(
      () => repository.updateRole(
        groupId: 'group-1',
        userId: 'user-2',
        role: GroupRole.viewer,
      ),
    ).thenAnswer((_) async => Right(group));
    when(
      () => repository.removeMember(groupId: 'group-1', userId: 'user-2'),
    ).thenAnswer((_) async => const Right(unit));

    await UpdateMemberRole(repository)(
      const UpdateMemberRoleParams(
        groupId: 'group-1',
        userId: 'user-2',
        role: GroupRole.viewer,
      ),
    );
    await RemoveMember(repository)(
      const RemoveMemberParams(groupId: 'group-1', userId: 'user-2'),
    );

    verify(
      () => repository.updateRole(
        groupId: 'group-1',
        userId: 'user-2',
        role: GroupRole.viewer,
      ),
    ).called(1);
    verify(
      () => repository.removeMember(groupId: 'group-1', userId: 'user-2'),
    ).called(1);
  });
}
