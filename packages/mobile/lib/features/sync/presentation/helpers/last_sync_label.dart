import 'package:intl/intl.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

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
