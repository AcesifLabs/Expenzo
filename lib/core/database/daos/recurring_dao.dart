import 'package:drift/drift.dart';
import '../../../features/recurring/domain/entities/recurring_transaction.dart'
    as domain;
import '../app_database.dart';
import '../tables/recurring_table.dart';

part 'recurring_dao.g.dart';

@DriftAccessor(tables: [RecurringTransactions])
class RecurringDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringDaoMixin {
  RecurringDao(super.db);

  Future<List<domain.RecurringTransaction>> getAllRecurring() async {
    final recurring = await select(recurringTransactions).get();
    return recurring.map(_mapToEntity).toList();
  }

  Stream<List<domain.RecurringTransaction>> watchAllRecurring() {
    return select(
      recurringTransactions,
    ).watch().map((recurring) => recurring.map(_mapToEntity).toList());
  }

  Future<domain.RecurringTransaction?> getRecurringById(String id) async {
    final query = select(recurringTransactions)..where((r) => r.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _mapToEntity(result) : null;
  }

  Future<void> insertRecurring(domain.RecurringTransaction recurring) async {
    await into(recurringTransactions).insert(
      RecurringTransactionsCompanion(
        id: Value(recurring.id ?? _generateId()),
        description: Value(recurring.description),
        amount: Value(recurring.amount),
        categoryId: Value(recurring.categoryId),
        frequency: Value(recurring.frequency.name),
        startDate: Value(recurring.startDate),
        endDate: Value(recurring.endDate),
        nextOccurrence: Value(recurring.nextOccurrence),
        isActive: Value(recurring.isActive),
        autoCreateExpense: Value(recurring.autoCreateExpense),
        dayOfMonth: Value(recurring.dayOfMonth),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> updateRecurring(domain.RecurringTransaction recurring) async {
    await (update(
      recurringTransactions,
    )..where((r) => r.id.equals(recurring.id!))).write(
      RecurringTransactionsCompanion(
        description: Value(recurring.description),
        amount: Value(recurring.amount),
        categoryId: Value(recurring.categoryId),
        frequency: Value(recurring.frequency.name),
        startDate: Value(recurring.startDate),
        endDate: Value(recurring.endDate),
        nextOccurrence: Value(recurring.nextOccurrence),
        isActive: Value(recurring.isActive),
        autoCreateExpense: Value(recurring.autoCreateExpense),
        dayOfMonth: Value(recurring.dayOfMonth),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> deleteRecurring(String id) async {
    await (delete(recurringTransactions)..where((r) => r.id.equals(id))).go();
  }

  Future<List<domain.RecurringTransaction>> getDueRecurring() async {
    final now = DateTime.now();
    final query = select(recurringTransactions)
      ..where(
        (r) =>
            r.isActive.equals(true) &
            r.nextOccurrence.isSmallerOrEqualValue(now),
      );
    final results = await query.get();
    return results.map(_mapToEntity).toList();
  }

  domain.RecurringTransaction _mapToEntity(RecurringTransaction r) {
    return domain.RecurringTransaction(
      id: r.id,
      description: r.description,
      amount: r.amount,
      categoryId: r.categoryId,
      frequency: _parseFrequency(r.frequency),
      startDate: r.startDate,
      endDate: r.endDate,
      nextOccurrence: r.nextOccurrence,
      isActive: r.isActive,
      autoCreateExpense: r.autoCreateExpense,
      dayOfMonth: r.dayOfMonth,
    );
  }

  domain.RecurringFrequency _parseFrequency(String frequency) {
    switch (frequency) {
      case 'daily':
        return domain.RecurringFrequency.daily;
      case 'weekly':
        return domain.RecurringFrequency.weekly;
      case 'monthly':
        return domain.RecurringFrequency.monthly;
      case 'yearly':
        return domain.RecurringFrequency.yearly;
      default:
        return domain.RecurringFrequency.monthly;
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
