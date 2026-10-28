import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/invite_code.dart';

String formatInviteExpiry(DateTime expiresAt, String locale) =>
    DateFormat.MMMd(locale).add_jm().format(expiresAt.toLocal());

String buildInviteShareText({
  required String groupName,
  required InviteCode invite,
  required String locale,
}) => t.family.invite.shareText(
  name: groupName,
  code: invite.code,
  time: formatInviteExpiry(invite.expiresAt, locale),
);
