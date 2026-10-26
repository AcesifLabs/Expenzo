import 'package:expense_tracker/core/theme/category_palette.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/group_summary.dart';
import '../../domain/entities/my_group.dart';

const maxShownAvatars = 5;

const _avatarColors = [
  CategoryPalette.mint,
  CategoryPalette.lavender,
  CategoryPalette.sky,
  CategoryPalette.amber,
  CategoryPalette.peach,
  CategoryPalette.slate,
];

String memberInitial(String? displayName) {
  final name = displayName?.trim() ?? '';

  return name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

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

double spendingBarRatio(MemberSpending member, List<MemberSpending> all) {
  var largest = 0.0;
  for (final m in all) {
    if (m.spent > largest) largest = m.spent;
  }

  return largest > 0 ? member.spent / largest : 0;
}

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

Color memberAvatarColor(int index) =>
    ColorUtils.fromHex(_avatarColors[index % _avatarColors.length].hex);

({List<GroupMember> shown, int more}) avatarSlice(List<GroupMember> members) {
  final shown = members.take(maxShownAvatars).toList();

  return (shown: shown, more: members.length - shown.length);
}
