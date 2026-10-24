/// A member's permission level in a Family Group (CONTEXT.md Group Role).
enum GroupRole {
  admin,
  member,
  viewer;

  /// The server's value; an unknown one reads as [viewer], the least access.
  static GroupRole fromApi(String? value) {
    for (final role in values) {
      if (role.name == value) return role;
    }

    return viewer;
  }

  String get apiValue => name;

  bool get isAdmin => this == admin;

  /// Admins and Members may add Records to Shared Budgets; Viewers only read.
  bool get canAssignSharedBudget => this != viewer;

  /// Only an Admin shares a budget into the group. Unsharing is the owner's
  /// right whatever their role, checked in `BudgetAccess`.
  bool get canShareBudget => isAdmin;
}
