import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/sync/sync_run_result.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/sync/domain/usecases/sync_now.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cached.dart';
import '../../domain/entities/my_group.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/create_invite.dart';
import '../../domain/usecases/delete_group.dart';
import '../../domain/usecases/get_group_summary.dart';
import '../../domain/usecases/get_my_group.dart';
import '../../domain/usecases/join_group.dart';
import '../../domain/usecases/leave_group.dart';
import '../../domain/usecases/remove_member.dart';
import '../../domain/usecases/update_member_role.dart';
import 'family_event.dart';
import 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final GetMyGroup getMyGroup;
  final GetGroupSummary getGroupSummary;
  final CreateGroup createGroup;
  final JoinGroup joinGroup;
  final CreateInvite createInvite;
  final UpdateMemberRole updateMemberRole;
  final RemoveMember removeMember;
  final LeaveGroup leaveGroup;
  final DeleteGroup deleteGroup;
  final GetSettings getSettings;
  final SyncNow syncNow;
  final DateTime Function() clock;

  static const _settingsFailure = CacheFailure(
    message: 'Settings could not be read for the currency',
  );

  FamilyBloc({
    required this.getMyGroup,
    required this.getGroupSummary,
    required this.createGroup,
    required this.joinGroup,
    required this.createInvite,
    required this.updateMemberRole,
    required this.removeMember,
    required this.leaveGroup,
    required this.deleteGroup,
    required this.getSettings,
    required this.syncNow,
    this.clock = DateTime.now,
  }) : super(const FamilyState()) {
    on<FamilyLoadRequested>(
      (event, emit) => _load(emit, preferCache: event.preferCache),
      transformer: restartable(),
    );
    on<FamilyRefreshRequested>(
      (_, emit) => _load(emit, preferCache: false),
      transformer: restartable(),
    );
    on<FamilyCreateRequested>(_onCreate, transformer: droppable());
    on<FamilyJoinRequested>(_onJoin, transformer: droppable());
    on<FamilyInviteRequested>(_onInvite, transformer: sequential());
    on<FamilyRoleChangeRequested>(_onRoleChange, transformer: sequential());
    on<FamilyMemberRemoveRequested>(_onRemove, transformer: sequential());
    on<FamilyLeaveRequested>(_onLeave, transformer: sequential());
    on<FamilyDeleteRequested>(_onDelete, transformer: sequential());
    on<FamilyFailureCleared>((_, emit) => emit(state.copyWith(failure: null)));
  }

  Future<void> _load(
    Emitter<FamilyState> emit, {
    required bool preferCache,
  }) async {
    if (preferCache && state.group == null) {
      final cached = await getMyGroup(
        const GetMyGroupParams(preferCache: true),
      );
      cached.fold(
        (_) => emit(state.copyWith(status: FamilyStatus.loading)),
        (group) =>
            emit(state.copyWith(status: FamilyStatus.ready, group: group)),
      );
    } else if (state.group == null) {
      emit(state.copyWith(status: FamilyStatus.loading));
    }
    final fresh = await getMyGroup(const GetMyGroupParams());
    fresh.fold(
      (failure) => emit(
        state.group == null
            ? state.copyWith(status: FamilyStatus.failure, failure: failure)
            : state.copyWith(status: FamilyStatus.ready),
      ),
      (group) => _emitGroup(emit, group),
    );

    final myGroup = state.myGroup;
    if (myGroup != null) await _fetchSummaryFor(myGroup, emit);
  }

  void _emitGroup(Emitter<FamilyState> emit, Cached<MyGroup?> group) {
    final removed = state.myGroup != null && group.value == null;
    emit(
      state.copyWith(
        status: FamilyStatus.ready,
        group: group,
        summary: group.value == null ? null : state.summary,
        lastAction: removed ? FamilyAction.removedFromGroup : state.lastAction,
      ),
    );
  }

  Future<void> _fetchSummaryFor(
    MyGroup group,
    Emitter<FamilyState> emit,
  ) async {
    final result = await getGroupSummary(GroupIdParams(group.group.id));
    result.fold(
      (failure) => _isNotInGroup(failure)
          ? _emitRemoved(emit)
          : emit(state.copyWith(summaryFailure: failure)),
      (summary) => emit(state.copyWith(summary: summary, summaryFailure: null)),
    );
  }

  Future<String?> _currencyCode() async {
    final settings = await getSettings(NoParams());

    return settings.fold((_) => null, (s) => s.currencyCode);
  }

  Future<void> _onCreate(
    FamilyCreateRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(state.copyWith(busy: true, failure: null));
    final currencyCode = await _currencyCode();
    if (currencyCode == null) {
      emit(state.copyWith(busy: false, failure: _settingsFailure));

      return;
    }

    final result = await createGroup(
      CreateGroupParams(
        name: event.name,
        currencyCode: currencyCode,
        monthlyBudget: event.monthlyBudget,
      ),
    );
    _afterGroupAction(emit, result, FamilyAction.created);
  }

  Future<void> _onJoin(
    FamilyJoinRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(state.copyWith(busy: true, failure: null));
    final currencyCode = await _currencyCode();
    if (currencyCode == null) {
      emit(state.copyWith(busy: false, failure: _settingsFailure));

      return;
    }
    final result = await joinGroup(
      JoinGroupParams(code: event.code, currencyCode: currencyCode),
    );
    if (result.isLeft()) {
      _afterGroupAction(emit, result, FamilyAction.joined);

      return;
    }

    final sync = await syncNow();
    _afterGroupAction(
      emit,
      result,
      sync == SyncRunResult.disabled
          ? FamilyAction.joinedSyncOff
          : FamilyAction.joined,
    );
  }

  void _afterGroupAction(
    Emitter<FamilyState> emit,
    Either<Failure, MyGroup> result,
    FamilyAction action,
  ) {
    result.fold(
      (failure) => _emitFailure(emit, failure),
      (group) => emit(
        state.copyWith(
          status: FamilyStatus.ready,
          group: Cached<MyGroup?>(group, fetchedAt: clock()),
          busy: false,
          lastAction: action,
        ),
      ),
    );
  }

  Future<void> _onInvite(
    FamilyInviteRequested event,
    Emitter<FamilyState> emit,
  ) async {
    final active = state.activeInviteAt(clock());
    if (!event.regenerate && active != null) {
      emit(state.copyWith(invite: active));

      return;
    }
    final groupId = state.myGroup?.group.id;
    if (groupId == null) return;
    emit(state.copyWith(busy: true, failure: null));
    final result = await createInvite(GroupIdParams(groupId));
    result.fold(
      (failure) => _emitFailure(emit, failure),
      (invite) => emit(
        state.copyWith(
          invite: invite,
          busy: false,
          lastAction: FamilyAction.invited,
        ),
      ),
    );
  }

  Future<void> _onRoleChange(
    FamilyRoleChangeRequested event,
    Emitter<FamilyState> emit,
  ) async {
    final previous = state.group;
    final group = previous?.value;
    if (previous == null || group == null) return;
    _applyOptimistic(emit, previous, [
      for (final m in group.members)
        m.userId == event.userId ? m.copyWith(role: event.role) : m,
    ]);
    final result = await updateMemberRole(
      UpdateMemberRoleParams(
        groupId: group.group.id,
        userId: event.userId,
        role: event.role,
      ),
    );
    result.fold(
      (failure) => _restore(emit, previous, failure),
      (updated) => emit(
        state.copyWith(
          group: Cached<MyGroup?>(updated, fetchedAt: clock()),
          busy: false,
          lastAction: FamilyAction.roleChanged,
        ),
      ),
    );
  }

  Future<void> _onRemove(
    FamilyMemberRemoveRequested event,
    Emitter<FamilyState> emit,
  ) async {
    final previous = state.group;
    final group = previous?.value;
    if (previous == null || group == null) return;
    _applyOptimistic(emit, previous, [
      for (final m in group.members)
        if (m.userId != event.userId) m,
    ]);
    final result = await removeMember(
      RemoveMemberParams(groupId: group.group.id, userId: event.userId),
    );
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      _restore(emit, previous, failure);

      return;
    }
    emit(state.copyWith(busy: false, lastAction: FamilyAction.removed));

    await _load(emit, preferCache: false);
  }

  void _applyOptimistic(
    Emitter<FamilyState> emit,
    Cached<MyGroup?> previous,
    List<GroupMember> members,
  ) {
    final group = previous.value;
    if (group == null) return;
    emit(
      state.copyWith(
        group: Cached<MyGroup?>(
          group.copyWith(members: members),
          fetchedAt: previous.fetchedAt,
          fromCache: previous.fromCache,
        ),
        busy: true,
        failure: null,
      ),
    );
  }

  void _restore(
    Emitter<FamilyState> emit,
    Cached<MyGroup?> previous,
    Failure failure,
  ) {
    emit(state.copyWith(group: previous));
    _emitFailure(emit, failure);
  }

  Future<void> _onLeave(
    FamilyLeaveRequested event,
    Emitter<FamilyState> emit,
  ) => _endMembership(emit, leaveGroup, FamilyAction.left);

  Future<void> _onDelete(
    FamilyDeleteRequested event,
    Emitter<FamilyState> emit,
  ) => _endMembership(emit, deleteGroup, FamilyAction.deleted);

  Future<void> _endMembership(
    Emitter<FamilyState> emit,
    UseCase<Unit, GroupIdParams> action,
    FamilyAction done,
  ) async {
    final groupId = state.myGroup?.group.id;
    if (groupId == null) return;
    emit(state.copyWith(busy: true, failure: null));
    final result = await action(GroupIdParams(groupId));
    result.fold(
      (failure) => _emitFailure(emit, failure),
      (_) => emit(
        state.copyWith(
          group: Cached<MyGroup?>(null, fetchedAt: clock()),
          summary: null,
          busy: false,
          lastAction: done,
        ),
      ),
    );
  }

  void _emitFailure(Emitter<FamilyState> emit, Failure failure) {
    if (_isNotInGroup(failure)) {
      _emitRemoved(emit);

      return;
    }
    emit(state.copyWith(busy: false, failure: failure));
  }

  void _emitRemoved(Emitter<FamilyState> emit) => emit(
    state.copyWith(
      status: FamilyStatus.ready,
      group: Cached<MyGroup?>(null, fetchedAt: clock()),
      summary: null,
      busy: false,
      lastAction: FamilyAction.removedFromGroup,
    ),
  );

  bool _isNotInGroup(Failure failure) =>
      failure.errorCode == FailureCodes.notInGroup;
}
