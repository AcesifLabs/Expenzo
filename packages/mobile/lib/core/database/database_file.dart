import 'dart:io';

import 'package:drift/isolate.dart' show DriftRemoteException;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The app's SQLite file in the documents folder.
const databaseFileName = 'expenzo_db.sqlite';

/// SQLite result codes for a file that is damaged or not a database.
const _sqliteCorrupt = 11;
const _sqliteNotADatabase = 26;

Future<File> databaseFile() async {
  final dir = await getApplicationDocumentsDirectory();

  return File(p.join(dir.path, databaseFileName));
}

/// Whether [error] says the database file itself is unreadable: damaged or
/// not a database. Retrying can't fix that; only a fresh file can.
bool isDatabaseFileError(Object error) {
  final cause = error is DriftRemoteException ? error.remoteCause : error;
  if (cause is! SqliteException) return false;
  final code = cause.extendedResultCode & 0xFF;

  return code == _sqliteCorrupt || code == _sqliteNotADatabase;
}

/// Moves [file] aside as `<name>.corrupt` (replacing an older one), with
/// its journal files, so the next open starts an empty database. The old
/// file stays for support to look at.
Future<void> setDatabaseFileAside(File file) async {
  if (await file.exists()) await file.rename('${file.path}.corrupt');
  for (final suffix in ['-wal', '-shm', '-journal']) {
    final journal = File('${file.path}$suffix');
    if (await journal.exists()) await journal.delete();
  }
}
