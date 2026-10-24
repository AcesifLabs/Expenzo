import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/sync/sync_run_result.dart';
import 'package:expense_tracker/features/family/domain/entities/cached.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/invite_code.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/create_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/create_invite.dart';
import 'package:expense_tracker/features/family/domain/usecases/delete_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/get_group_summary.dart';
import 'package:expense_tracker/features/family/domain/usecases/get_my_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/join_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/leave_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/remove_member.dart';
import 'package:expense_tracker/features/family/domain/usecases/update_member_role.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_event.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_state.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/sync/domain/usecases/sync_now.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/factories/family_factory.dart';
import '../../../../support/factories/user_settings_factory.dart';

class _GetMyGroup extends Mock implements GetMyGroup {}

class _GetGroupSummary extends Mock implements GetGroupSummary {}

class _CreateGroup extends Mock implements CreateGroup {}

class _JoinGroup extends Mock implements JoinGroup {}

class _CreateInvite extends Mock implements CreateInvite {}

class _UpdateMemberRole extends Mock implements UpdateMemberRole {}

class _RemoveMember extends Mock implements RemoveMember {}

class _LeaveGroup extends Mock implements LeaveGroup {}

class _DeleteGroup extends Mock implements DeleteGroup {}

class _GetSettings extends Mock implements GetSettings {}

class _SyncNow extends Mock implements SyncNow {}

void main() {
  final now = DateTime.utc(2026, 4, 15, 12);
  final earlier = DateTime.utc(2026, 4, 14);
  const offline = NetworkFailure(message: 'offline');
  late _GetMyGroup getMyGroup;
  late _GetGroupSummary getSummary;
  late _CreateGroup createGroup;
  late _JoinGroup joinGroup;
  late _CreateInvite createInvite;
  late _UpdateMemberRole updateRole;
  late _RemoveMember removeMember;
  late _LeaveGroup leaveGroup;
  late _DeleteGroup deleteGroup;
  late _GetSettings getSettings;
  late _SyncNow syncNow;
  late FamilyBloc bloc;

  setUpAll(() {
    registerFallbackValue(const GetMyGroupParams());
    registerFallbackValue(const GroupIdParams('x'));
    registerFallbackValue(
      const CreateGroupParams(name: 'x', currencyCode: 'BDT'),
    );
    registerFallbackValue(
      const JoinGroupParams(code: 'x', currencyCode: 'BDT'),
    );
    registerFallbackValue(
      const UpdateMemberRoleParams(
        groupId: 'x',
        userId: 'x',
        role: GroupRole.member,
      ),
    );
    registerFallbackValue(const RemoveMemberParams(groupId: 'x', userId: 'x'));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    getMyGroup = _GetMyGroup();
    getSummary = _GetGroupSummary();
    createGroup = _CreateGroup();
    joinGroup = _JoinGroup();
    createInvite = _CreateInvite();
    updateRole = _UpdateMemberRole();
    removeMember = _RemoveMember();
    leaveGroup = _LeaveGroup();
    deleteGroup = _DeleteGroup();
    getSettings = _GetSettings();
    syncNow = _SyncNow();
    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => Right(makeUserSettings(currencyCode: 'BDT')));
    when(() => getSummary(any())).thenAnswer(
      (_) async => Right(Cached(makeGroupSummary(), fetchedAt: now)),
    );
    bloc = FamilyBloc(
      getMyGroup: getMyGroup,
      getGroupSummary: getSummary,
      createGroup: createGroup,
      joinGroup: joinGroup,
      createInvite: createInvite,
      updateMemberRole: updateRole,
      removeMember: removeMember,
      leaveGroup: leaveGroup,
      deleteGroup: deleteGroup,
      getSettings: getSettings,
      syncNow: syncNow,
      clock: () => now,
    );
  });

  tearDown(() => bloc.close());

  void groupIs({
    Cached<MyGroup?>? cached,
    Either<Failure, Cached<MyGroup?>>? fresh,
  }) {
    when(
      () => getMyGroup(const GetMyGroupParams(preferCache: true)),
    ).thenAnswer(
      (_) async => cached == null
          ? const Left(CacheFailure(message: 'none'))
          : Right(cached),
    );
    when(() => getMyGroup(const GetMyGroupParams())).thenAnswer(
      (_) async => fresh ?? Right(Cached(makeMyGroup(), fetchedAt: now)),
    );
  }

  Future<FamilyState> settle() async {
    await pumpEventQueue();

    return bloc.state;
  }

  group('load', () {
    test(
      'shows the cached group first, then the fresh one and its summary',
      () async {
        groupIs(
          cached: Cached(makeMyGroup(), fetchedAt: earlier, fromCache: true),
        );

        final states = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<FamilyState>().having((s) => s.fromCache, 'fromCache', isTrue),
            isA<FamilyState>().having(
              (s) => s.group?.fetchedAt,
              'fetchedAt',
              now,
            ),
            isA<FamilyState>().having((s) => s.summary, 'summary', isNotNull),
          ]),
        );
        bloc.add(const FamilyLoadRequested());
        await states;
      },
    );

    test(
      'offline with a cache stays ready, from cache, with lastUpdated',
      () async {
        groupIs(
          cached: Cached(makeMyGroup(), fetchedAt: earlier, fromCache: true),
          fresh: const Left(offline),
        );
        when(() => getSummary(any())).thenAnswer(
          (_) async => Right(
            Cached(makeGroupSummary(), fetchedAt: earlier, fromCache: true),
          ),
        );

        bloc.add(const FamilyLoadRequested());
        final state = await settle();

        expect(state.status, FamilyStatus.ready);
        expect(state.fromCache, isTrue);
        expect(state.lastUpdated, earlier);
      },
    );

    test('not in a group skips the summary', () async {
      groupIs(fresh: Right(Cached(null, fetchedAt: now)));

      bloc.add(const FamilyLoadRequested());
      await settle();

      verifyNever(() => getSummary(any()));
    });

    test('a summary failure only sets summaryFailure', () async {
      groupIs(
        cached: Cached(makeMyGroup(), fetchedAt: earlier, fromCache: true),
        fresh: const Left(offline),
      );
      when(
        () => getSummary(any()),
      ).thenAnswer((_) async => const Left(offline));

      bloc.add(const FamilyLoadRequested());
      final state = await settle();

      expect(state.myGroup, isNotNull);
      expect(state.failure, isNull);
      expect(state.summaryFailure, offline);
    });

    test(
      'the group turning null on refresh means removed from the group',
      () async {
        groupIs(fresh: Right(Cached(makeMyGroup(), fetchedAt: now)));
        bloc.add(const FamilyLoadRequested(preferCache: false));
        await settle();

        groupIs(fresh: Right(Cached(null, fetchedAt: now)));
        bloc.add(const FamilyRefreshRequested());
        final state = await settle();

        expect(state.lastAction, FamilyAction.removedFromGroup);
      },
    );
  });

  group('create and join', () {
    test('create uses the settings currency and makes no invite', () async {
      when(
        () => createGroup(any()),
      ).thenAnswer((_) async => Right(makeMyGroup()));

      bloc.add(const FamilyCreateRequested(name: 'Rahman Family'));
      final state = await settle();

      verify(
        () => createGroup(
          const CreateGroupParams(name: 'Rahman Family', currencyCode: 'BDT'),
        ),
      ).called(1);
      verifyNever(() => createInvite(any()));
      expect(state.lastAction, FamilyAction.created);
    });

    test('join syncs right away', () async {
      when(
        () => joinGroup(any()),
      ).thenAnswer((_) async => Right(makeMyGroup(myRole: GroupRole.member)));
      when(() => syncNow()).thenAnswer((_) async => SyncRunResult.success);

      bloc.add(const FamilyJoinRequested('RF4XK2'));
      final state = await settle();

      verify(() => syncNow()).called(1);
      expect(state.lastAction, FamilyAction.joined);
    });

    test('join with Sync off says so', () async {
      when(
        () => joinGroup(any()),
      ).thenAnswer((_) async => Right(makeMyGroup(myRole: GroupRole.member)));
      when(() => syncNow()).thenAnswer((_) async => SyncRunResult.disabled);

      bloc.add(const FamilyJoinRequested('RF4XK2'));

      expect((await settle()).lastAction, FamilyAction.joinedSyncOff);
    });

    for (final code in [
      FailureCodes.currencyMismatch,
      FailureCodes.groupFull,
    ]) {
      test('a $code failure reaches the screen and does not sync', () async {
        when(() => joinGroup(any())).thenAnswer(
          (_) async => Left(ServerFailure(message: code, errorCode: code)),
        );

        bloc.add(const FamilyJoinRequested('RF4XK2'));
        final state = await settle();

        expect(state.failure?.errorCode, code);
        expect(state.busy, isFalse);
        verifyNever(() => syncNow());
      });
    }
  });

  group('invite', () {
    final active = InviteCode(
      code: 'RF4XK2',
      expiresAt: now.add(const Duration(hours: 1)),
    );

    Future<void> inGroup(MyGroup group) async {
      groupIs(fresh: Right(Cached(group, fetchedAt: now)));
      bloc.add(const FamilyLoadRequested(preferCache: false));
      await settle();
    }

    test('reuses the active invite without making a code', () async {
      await inGroup(makeMyGroup(invite: active));

      bloc.add(const FamilyInviteRequested());
      final state = await settle();

      expect(state.activeInviteAt(now), active);
      verifyNever(() => createInvite(any()));
    });

    test('regenerate makes a new code', () async {
      await inGroup(makeMyGroup(invite: active));
      final fresh = InviteCode(
        code: 'NEW234',
        expiresAt: now.add(const Duration(hours: 48)),
      );
      when(() => createInvite(any())).thenAnswer((_) async => Right(fresh));

      bloc.add(const FamilyInviteRequested(regenerate: true));
      final state = await settle();

      expect(state.activeInviteAt(now), fresh);
      expect(state.lastAction, FamilyAction.invited);
    });
  });

  group('members', () {
    setUp(() async {
      groupIs(fresh: Right(Cached(makeMyGroup(), fetchedAt: now)));
      bloc.add(const FamilyLoadRequested(preferCache: false));
      await settle();
    });

    GroupRole? roleOf(FamilyState s, String userId) =>
        s.myGroup?.members.firstWhere((m) => m.userId == userId).role;

    test('a role change shows at once, then the server group', () async {
      final updated = makeMyGroup(
        members: [
          makeGroupMember(),
          makeGroupMember(userId: 'user-2', role: GroupRole.viewer),
        ],
      );
      when(() => updateRole(any())).thenAnswer((_) async => Right(updated));

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<FamilyState>().having(
            (s) => roleOf(s, 'user-2'),
            'optimistic role',
            GroupRole.viewer,
          ),
          isA<FamilyState>().having((s) => s.myGroup, 'server group', updated),
        ]),
      );
      bloc.add(
        const FamilyRoleChangeRequested(
          userId: 'user-2',
          role: GroupRole.viewer,
        ),
      );
      await states;
    });

    test('a failed role change puts the old list back', () async {
      when(
        () => updateRole(any()),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'x')));

      bloc.add(
        const FamilyRoleChangeRequested(
          userId: 'user-2',
          role: GroupRole.viewer,
        ),
      );
      final state = await settle();

      expect(roleOf(state, 'user-2'), GroupRole.member);
      expect(state.failure, isNotNull);
    });

    test('a failed removal brings the member back', () async {
      when(
        () => removeMember(any()),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'x')));

      bloc.add(const FamilyMemberRemoveRequested('user-2'));
      final state = await settle();

      expect(state.myGroup?.members.map((m) => m.userId), contains('user-2'));
    });

    test('NOT_IN_GROUP from an action means removed from the group', () async {
      when(() => updateRole(any())).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'x', errorCode: FailureCodes.notInGroup),
        ),
      );

      bloc.add(
        const FamilyRoleChangeRequested(
          userId: 'user-2',
          role: GroupRole.viewer,
        ),
      );
      final state = await settle();

      expect(state.lastAction, FamilyAction.removedFromGroup);
      expect(state.myGroup, isNull);
    });

    test('leaving clears the group', () async {
      when(() => leaveGroup(any())).thenAnswer((_) async => const Right(unit));

      bloc.add(const FamilyLeaveRequested());
      final state = await settle();

      expect(state.lastAction, FamilyAction.left);
      expect(state.myGroup, isNull);
    });

    test('FamilyFailureCleared resets the failure', () async {
      when(
        () => updateRole(any()),
      ).thenAnswer((_) async => const Left(ServerFailure(message: 'x')));
      bloc.add(
        const FamilyRoleChangeRequested(
          userId: 'user-2',
          role: GroupRole.viewer,
        ),
      );
      await settle();

      bloc.add(const FamilyFailureCleared());

      expect((await settle()).failure, isNull);
    });
  });
}
