import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';

class RecordBudgetLinkRepair {
  final RecordDao recordDao;
  final RecordRemoteDatasource remote;
  final SharedPreferences prefs;

  final String? Function() currentUserId;

  static const doneKeyPrefix = 'record_budget_links_repaired_';

  Future<void>? _running;

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
