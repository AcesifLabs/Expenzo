import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';

import '../entities/my_group.dart';

/// Who may change a Budget and who may add Records to it, from the cached
/// Family Group (ADR 0008; CONTEXT.md Shared Budget, Group Role):
/// - personal budgets: always;
/// - a Shared Budget: its owner edits and unshares it whatever their role;
///   other members see it read-only;
/// - Admins and Members may add Records to their group's Shared Budgets;
///   Viewers may not.
class BudgetAccess {
  final MyGroup? Function() currentGroup;

  /// The group a new share goes into, and its name for the form.
  String? get currentGroupId => currentGroup()?.group.id;
  String? get currentGroupName => currentGroup()?.group.name;

  const BudgetAccess({required this.currentGroup});

  /// Access with no group, for code that runs without the Family module.
  BudgetAccess.none() : currentGroup = _noGroup;

  bool canEdit(Budget budget) {
    final groupId = budget.groupId;
    if (groupId == null) return true;
    final id = budget.id;
    final group = currentGroup();
    // A shared row the phone cannot place; the next /groups/me drops it.
    if (group == null || id == null) return false;
    if (group.ownsBudget(id)) return true;

    // Shared on this phone and not listed by the server yet.
    return !group.listsBudget(id) &&
        group.myRole.isAdmin &&
        groupId == group.group.id;
  }

  /// The owner's right, whatever their role (a demoted Admin keeps it).
  bool canUnshare(Budget budget) => budget.groupId != null && canEdit(budget);

  /// Only an Admin shares a budget into the group: a new one ([budget] null)
  /// or one they may edit.
  bool canShare(Budget? budget) {
    final group = currentGroup();
    if (group == null || !group.myRole.canShareBudget) return false;

    return budget == null || canEdit(budget);
  }

  /// Whether a Record may be linked to a budget shared into [groupId]
  /// (null: a personal budget).
  bool canAssignTo(String? groupId) {
    if (groupId == null) return true;
    final group = currentGroup();

    return group != null &&
        group.group.id == groupId &&
        group.myRole.canAssignSharedBudget;
  }

  /// The Currency to show a budget shared into [groupId] in: its group's.
  /// Null for a personal budget or a group the phone does not know.
  String? currencyFor(String? groupId) {
    final group = currentGroup();
    if (groupId == null || group == null || group.group.id != groupId) {
      return null;
    }

    return group.group.currencyCode;
  }

  List<Budget> assignable(List<Budget> budgets) =>
      budgets.where((budget) => canAssignTo(budget.groupId)).toList();

  static MyGroup? _noGroup() => null;
}
