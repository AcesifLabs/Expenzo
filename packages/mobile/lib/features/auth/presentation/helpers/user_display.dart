import 'package:flutter/widgets.dart';

import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/entities/user.dart';

/// The first word of the Google name, or null when the account has none.
String? userFirstName(User user) {
  final first = (user.displayName ?? '').trim().split(' ').first;

  return first.isEmpty ? null : first;
}

/// The avatar letter: from the name, else the email, else '?'. One grapheme,
/// so a Bangla conjunct or an emoji isn't cut in half.
String userInitial(User user) {
  for (final source in [user.displayName, user.email]) {
    final trimmed = (source ?? '').trim();
    if (trimmed.isNotEmpty) return trimmed.characters.first.toUpperCase();
  }

  return '?';
}

/// The Google name, else the email's local part, else a generic label.
String userDisplayName(User user) {
  final name = (user.displayName ?? '').trim();
  if (name.isNotEmpty) return name;
  final local = (user.email ?? '').split('@').first.trim();

  return local.isNotEmpty ? local : t.dashboard.userFallback;
}
