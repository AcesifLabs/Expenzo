import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/invite_code.dart';

/// When the code stops working, in local time ("Mar 3, 4:00 PM"). An
/// absolute time on purpose, not a countdown. Digits are Latin in every
/// language (set app-wide in main.dart).
String formatInviteExpiry(DateTime expiresAt, String locale) =>
    DateFormat.MMMd(locale).add_jm().format(expiresAt.toLocal());

/// The message the Admin sends through the share sheet.
String buildInviteShareText({
  required String groupName,
  required InviteCode invite,
  required String locale,
}) => t.family.invite.shareText(
  name: groupName,
  code: invite.code,
  time: formatInviteExpiry(invite.expiresAt, locale),
);
