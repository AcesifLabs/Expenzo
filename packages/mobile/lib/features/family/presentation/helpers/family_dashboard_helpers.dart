import 'package:expense_tracker/core/theme/category_palette.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/group_summary.dart';
import '../../domain/entities/my_group.dart';

/// Avatars shown before "+N".
const maxShownAvatars = 5;

/// The category palette without the income (teal) and expense (rose)
/// colours, mint first so the first member, usually the Admin, gets the
/// Brand Color (ADR 0003).
const _avatarColors = [
  CategoryPalette.mint,
  CategoryPalette.lavender,
  CategoryPalette.sky,
  CategoryPalette.amber,
  CategoryPalette.peach,
  CategoryPalette.slate,
];

/// The first letter of a name, upper-cased; "?" without one. One
/// grapheme, so a Bangla conjunct isn't cut in half (like `userInitial`).
String memberInitial(String? displayName) {
  final name = displayName?.trim() ?? '';

  return name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

/// "Karim (you)", "Karim", or "Family member" without a name.
String memberLabel({
  required String userId,
  required String? displayName,
  required String myUserId,
}) {
  final dashboardT = t.family.dashboard;
  final name = displayName?.trim();
  final shown = name == null || name.isEmpty ? dashboardT.memberFallback : name;

  return userId == myUserId ? dashboardT.you(name: shown) : shown;
}

/// The member's bar length: their share of the biggest spender's amount.
double spendingBarRatio(MemberSpending member, List<MemberSpending> all) {
  var largest = 0.0;
  for (final m in all) {
    if (m.spent > largest) largest = m.spent;
  }

  return largest > 0 ? member.spent / largest : 0;
}

/// When cached numbers were fetched: a time today, else date and time.
String lastUpdatedLabel(DateTime fetchedAt, DateTime now, String locale) {
  final local = fetchedAt.toLocal();
  final today =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;

  return today
      ? DateFormat.jm(locale).format(local)
      : DateFormat.MMMd(locale).add_jm().format(local);
}

/// The avatar colour of the member at [index] in `MyGroup.members`
/// (oldest first), so a member keeps their colour on every screen.
Color memberAvatarColor(int index) =>
    ColorUtils.fromHex(_avatarColors[index % _avatarColors.length].hex);

/// The first [maxShownAvatars] members, and how many are left over.
({List<GroupMember> shown, int more}) avatarSlice(List<GroupMember> members) {
  final shown = members.take(maxShownAvatars).toList();

  return (shown: shown, more: members.length - shown.length);
}
