import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/expenses_table.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  Stream<List<Expense>> watchExpenses() {
    return (select(
      expenses,
    )..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
  }

  Future<List<Expense>> getAllExpenses({int? limit, int? offset}) {
    final query = select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)]);
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  Future<Expense?> getExpenseById(int id) {
    return (select(expenses)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) {
    return (select(expenses)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<Expense>> getExpensesByCategory(int categoryId) {
    return (select(expenses)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  /// Bulk insert with transaction for efficiency on low-end storage.
  Future<void> insertExpensesBatch(List<ExpensesCompanion> companions) async {
    await transaction(() async {
      for (final companion in companions) {
        await into(expenses).insert(companion);
      }
    });
  }

  Future<bool> updateExpense(ExpensesCompanion expense) {
    return update(
      expenses,
    ).replace(expense.copyWith(updatedAt: Value(DateTime.now().toUtc())));
  }

  Future<int> deleteExpense(int id) {
    return (delete(expenses)..where((t) => t.id.equals(id))).go();
  }

  Future<int> getExpenseCountByCategory(int categoryId) async {
    final count = countAll();
    final query = selectOnly(expenses)
      ..addColumns([count])
      ..where(expenses.categoryId.equals(categoryId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<bool> existsBySourceId(String sourceId) async {
    final count = countAll();
    final query = selectOnly(expenses)
      ..addColumns([count])
      ..where(expenses.sourceId.equals(sourceId));
    final result = await query.getSingle();
    final cnt = result.read(count) ?? 0;
    return cnt > 0;
  }

  /// Batch lookup: returns the set of sourceIds that already exist in the DB.
  /// Uses a single SQL query with IN clause instead of N individual queries.
  Future<Set<String>> getExistingSourceIds(List<String> sourceIds) async {
    if (sourceIds.isEmpty) return {};

    final query = selectOnly(expenses)
      ..addColumns([expenses.sourceId])
      ..where(expenses.sourceId.isIn(sourceIds));

    final results = await query.get();
    return results
        .map((row) => row.read(expenses.sourceId))
        .whereType<String>()
        .toSet();
  }
}
