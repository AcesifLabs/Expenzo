import 'dart:io';

import 'package:drift/isolate.dart' show DriftRemoteException;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const databaseFileName = 'expenzo_db.sqlite';

const _sqliteCorrupt = 11;
const _sqliteNotADatabase = 26;

Future<File> databaseFile() async {
  final dir = await getApplicationDocumentsDirectory();

  return File(p.join(dir.path, databaseFileName));
}

bool isDatabaseFileError(Object error) {
  final cause = error is DriftRemoteException ? error.remoteCause : error;
  if (cause is! SqliteException) return false;
  final code = cause.extendedResultCode & 0xFF;

  return code == _sqliteCorrupt || code == _sqliteNotADatabase;
}

Future<void> setDatabaseFileAside(File file) async {
  if (await file.exists()) await file.rename('${file.path}.corrupt');
  for (final suffix in ['-wal', '-shm', '-journal']) {
    final journal = File('${file.path}$suffix');
    if (await journal.exists()) await journal.delete();
  }
}
