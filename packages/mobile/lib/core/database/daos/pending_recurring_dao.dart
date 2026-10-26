import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/pending_recurring_table.dart';

part 'pending_recurring_dao.g.dart';

@DriftAccessor(tables: [PendingRecurring])
class PendingRecurringDao extends DatabaseAccessor<AppDatabase>
    with _$PendingRecurringDaoMixin {
  PendingRecurringDao(super.db);
}
