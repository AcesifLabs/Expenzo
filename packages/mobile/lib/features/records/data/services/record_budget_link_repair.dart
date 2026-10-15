import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';

/// Sends this device's record budget links to the server once per account.
///
/// The server dropped budget links until it had a column for them, so its
/// older records have none. The server fills a link only where it has none:
/// it never creates a record, changes any other field or touches `updatedAt`
/// (ADR 0012). The repair counts as done for the signed-in account only after
/// every batch is accepted.
class RecordBudgetLinkRepair {
  final RecordDao recordDao;
  final RecordRemoteDatasource remote;
  final SharedPreferences prefs;

  /// The signed-in account, or null when signed out.
  final String? Function() currentUserId;

  /// Followed by the user id; `LocalDataPrefs` wipes every account's
  /// flag.
  static const doneKeyPrefix = 'record_budget_links_repaired_';

  Future<void>? _running;

  /// True until the signed-in account's links have been sent. Signed out it
  /// stays true, so local links are kept until someone can send them.
  bool get isPending {
    final userId = currentUserId();

    return userId == null || !(prefs.getBool('$doneKeyPrefix$userId') ?? false);
  }

  RecordBudgetLinkRepair({
    required this.recordDao,
    required this.remote,
    required this.prefs,
    required this.currentUserId,
  });

  /// Throws [ServerException] when a batch is rejected or the server cannot be
  /// reached; the repair then stays pending and runs after the next sync.
  /// Calls made while a run is in progress wait for that run.
  Future<void> runOnce() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    final userId = currentUserId();
    if (userId == null || !isPending) return;

    final links = await recordDao.getBudgetLinks();
    for (
      var i = 0;
      i < links.length;
      i += AppConstants.fillRecordBudgetLinksBatchSize
    ) {
      final end = i + AppConstants.fillRecordBudgetLinksBatchSize < links.length
          ? i + AppConstants.fillRecordBudgetLinksBatchSize
          : links.length;
      await remote.fillMissingBudgetLinks(links.sublist(i, end));
    }
    await prefs.setBool('$doneKeyPrefix$userId', true);
  }
}
