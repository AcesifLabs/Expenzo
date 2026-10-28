import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../../domain/entities/cached.dart';
import '../../domain/entities/group_summary.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/entities/my_group.dart';

enum FamilyStatus { initial, loading, ready, failure }

enum FamilyAction {
  created,
  joined,

  joinedSyncOff,
  invited,
  roleChanged,
  removed,
  left,
  deleted,

  removedFromGroup,
}

class FamilyState extends Equatable {
  final FamilyStatus status;

  final Cached<MyGroup?>? group;
  final Cached<GroupSummary>? summary;

  final Failure? summaryFailure;

  final InviteCode? invite;

  final bool busy;
  final Failure? failure;
  final FamilyAction? lastAction;

  MyGroup? get myGroup => group?.value;

  bool get fromCache =>
      (group?.fromCache ?? false) || (summary?.fromCache ?? false);

  DateTime? get lastUpdated {
    if (!fromCache) return null;
    final times = [?group?.fetchedAt, ?summary?.fetchedAt];

    return times.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  @override
  List<Object?> get props => [
    status,
    group,
    summary,
    summaryFailure,
    invite,
    busy,
    failure,
    lastAction,
  ];

  const FamilyState({
    this.status = FamilyStatus.initial,
    this.group,
    this.summary,
    this.summaryFailure,
    this.invite,
    this.busy = false,
    this.failure,
    this.lastAction,
  });

  InviteCode? activeInviteAt(DateTime now) {
    final invite = this.invite ?? myGroup?.invite;

    return invite == null || invite.isExpiredAt(now) ? null : invite;
  }

  FamilyState copyWith({
    FamilyStatus? status,
    Object? group = _keep,
    Object? summary = _keep,
    Object? summaryFailure = _keep,
    Object? invite = _keep,
    bool? busy,
    Object? failure = _keep,
    Object? lastAction = _keep,
  }) {
    return FamilyState(
      status: status ?? this.status,
      group: group == _keep ? this.group : group as Cached<MyGroup?>?,
      summary: summary == _keep
          ? this.summary
          : summary as Cached<GroupSummary>?,
      summaryFailure: summaryFailure == _keep
          ? this.summaryFailure
          : summaryFailure as Failure?,
      invite: invite == _keep ? this.invite : invite as InviteCode?,
      busy: busy ?? this.busy,
      failure: failure == _keep ? this.failure : failure as Failure?,
      lastAction: lastAction == _keep
          ? this.lastAction
          : lastAction as FamilyAction?,
    );
  }
}

class _Keep {
  const _Keep();
}

const _keep = _Keep();
