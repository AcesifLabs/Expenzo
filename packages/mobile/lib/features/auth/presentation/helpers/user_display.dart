import 'package:flutter/widgets.dart';

import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/entities/user.dart';

String? userFirstName(User user) {
  final first = (user.displayName ?? '').trim().split(' ').first;

  return first.isEmpty ? null : first;
}

String userInitial(User user) {
  for (final source in [user.displayName, user.email]) {
    final trimmed = (source ?? '').trim();
    if (trimmed.isNotEmpty) return trimmed.characters.first.toUpperCase();
  }

  return '?';
}

String userDisplayName(User user) {
  final name = (user.displayName ?? '').trim();
  if (name.isNotEmpty) return name;
  final local = (user.email ?? '').split('@').first.trim();

  return local.isNotEmpty ? local : t.dashboard.userFallback;
}
