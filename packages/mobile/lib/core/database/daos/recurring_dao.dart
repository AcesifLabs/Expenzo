import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recurring_table.dart';

part 'recurring_dao.g.dart';

@DriftAccessor(tables: [RecurringTransactions])
class RecurringDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringDaoMixin {
  RecurringDao(super.db);

  Future<List<RecurringTransaction>> getAllRecurring() {
    return select(recurringTransactions).get();
  }

  Stream<List<RecurringTransaction>> watchAllRecurring() {
    return select(recurringTransactions).watch();
  }

  Future<RecurringTransaction?> getRecurringById(String id) {
    final query = select(recurringTransactions)..where((r) => r.id.equals(id));

    return query.getSingleOrNull();
  }

  Future<void> insertRecurring(RecurringTransactionsCompanion companion) async {
    await into(recurringTransactions).insert(companion);
  }

  Future<void> updateRecurring(RecurringTransactionsCompanion companion) async {
    await (update(
      recurringTransactions,
    )..where((r) => r.id.equals(companion.id.value))).write(companion);
  }

  Future<void> updateRecurringBatch(
    List<RecurringTransactionsCompanion> companions,
  ) async {
    await transaction(() async {
      for (final companion in companions) {
        await updateRecurring(companion);
      }
    });
  }

  Future<void> deleteRecurring(String id) async {
    await (delete(recurringTransactions)..where((r) => r.id.equals(id))).go();
  }

  Future<List<RecurringTransaction>> getDueRecurring() {
    final now = DateTime.now();
    final query = select(recurringTransactions)
      ..where(
        (r) =>
            r.isActive.equals(true) &
            r.nextOccurrence.isSmallerOrEqualValue(now),
      );

    return query.get();
  }
}
