import 'package:intl/intl.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// "Today, 3:45 AM", "Yesterday, 9:10 PM" or the full date and time, in the
/// app language. The formatters are built per call: they pick up
/// `Intl.defaultLocale`, which follows the app language.
String lastSyncLabel(DateTime at, DateTime now) {
  final syncT = t.settings.sync;
  final local = at.toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  final time = DateFormat.jm().format(local);

  if (day == today) return syncT.today(time: time);
  if (day == DateTime(now.year, now.month, now.day - 1)) {
    return syncT.yesterday(time: time);
  }

  return DateFormat.yMMMd().add_jm().format(local);
}
