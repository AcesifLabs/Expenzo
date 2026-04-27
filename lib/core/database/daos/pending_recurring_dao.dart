import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/pending_recurring_table.dart';

part 'pending_recurring_dao.g.dart';

@DriftAccessor(tables: [PendingRecurring])
class PendingRecurringDao extends DatabaseAccessor<AppDatabase>
    with _$PendingRecurringDaoMixin {
  PendingRecurringDao(super.db);

  Stream<List<PendingRecurringData>> watchPending() {
    return (select(
      pendingRecurring,
    )..orderBy([(t) => OrderingTerm.asc(t.dueDate)])).watch();
  }

  Future<List<PendingRecurringData>> getAllPending() {
    return (select(
      pendingRecurring,
    )..orderBy([(t) => OrderingTerm.asc(t.dueDate)])).get();
  }

  Future<int> addPending(PendingRecurringCompanion pending) {
    return into(pendingRecurring).insert(pending);
  }

  Future<int> removePending(int id) {
    return (delete(pendingRecurring)..where((t) => t.id.equals(id))).go();
  }
}
