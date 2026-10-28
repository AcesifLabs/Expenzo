import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';

import '../entities/my_group.dart';

class BudgetAccess {
  final MyGroup? Function() currentGroup;

  String? get currentGroupId => currentGroup()?.group.id;
  String? get currentGroupName => currentGroup()?.group.name;

  const BudgetAccess({required this.currentGroup});

  BudgetAccess.none() : currentGroup = _noGroup;

  bool canEdit(Budget budget) {
    final groupId = budget.groupId;
    if (groupId == null) return true;
    final id = budget.id;
    final group = currentGroup();

    if (group == null || id == null) return false;
    if (group.ownsBudget(id)) return true;

    return !group.listsBudget(id) &&
        group.myRole.isAdmin &&
        groupId == group.group.id;
  }

  bool canUnshare(Budget budget) => budget.groupId != null && canEdit(budget);

  bool canShare(Budget? budget) {
    final group = currentGroup();
    if (group == null || !group.myRole.canShareBudget) return false;

    return budget == null || canEdit(budget);
  }

  bool canAssignTo(String? groupId) {
    if (groupId == null) return true;
    final group = currentGroup();

    return group != null &&
        group.group.id == groupId &&
        group.myRole.canAssignSharedBudget;
  }

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
