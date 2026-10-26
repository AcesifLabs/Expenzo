enum GroupRole {
  admin,
  member,
  viewer;

  static GroupRole fromApi(String? value) {
    for (final role in values) {
      if (role.name == value) return role;
    }

    return viewer;
  }

  String get apiValue => name;

  bool get isAdmin => this == admin;

  bool get canAssignSharedBudget => this != viewer;

  bool get canShareBudget => isAdmin;
}
