import 'package:drift/drift.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/recurring_dao.dart';
import '../../domain/entities/recurring_transaction.dart' as domain;

abstract class RecurringLocalDatasource {
  Future<List<domain.RecurringTransaction>> getRecurringList();
  Future<domain.RecurringTransaction?> getRecurringById(String id);
  Future<void> createRecurring(domain.RecurringTransaction recurring);
  Future<void> updateRecurring(domain.RecurringTransaction recurring);
  Future<void> updateRecurringBatch(
    List<domain.RecurringTransaction> transactions,
  );
  Future<void> deleteRecurring(String id);
  Stream<List<domain.RecurringTransaction>> watchRecurringList();
  Future<List<domain.RecurringTransaction>> getDueRecurring();
}

class RecurringLocalDatasourceImpl implements RecurringLocalDatasource {
  final RecurringDao recurringDao;

  RecurringLocalDatasourceImpl({required this.recurringDao});

  @override
  Future<List<domain.RecurringTransaction>> getRecurringList() async {
    final results = await recurringDao.getAllRecurring();

    return results.map(_mapToEntity).toList();
  }

  @override
  Future<domain.RecurringTransaction?> getRecurringById(String id) async {
    final result = await recurringDao.getRecurringById(id);

    return result != null ? _mapToEntity(result) : null;
  }

  @override
  Future<void> createRecurring(domain.RecurringTransaction recurring) async {
    final now = DateTime.now().toUtc();
    await recurringDao.insertRecurring(
      RecurringTransactionsCompanion(
        id: Value(
          recurring.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ),
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
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateRecurring(domain.RecurringTransaction recurring) async {
    await recurringDao.updateRecurring(_toCompanion(recurring));
  }

  @override
  Future<void> updateRecurringBatch(
    List<domain.RecurringTransaction> transactions,
  ) async {
    final companions = transactions.map(_toCompanion).toList();
    await recurringDao.updateRecurringBatch(companions);
  }

  @override
  Future<void> deleteRecurring(String id) async {
    await recurringDao.deleteRecurring(id);
  }

  @override
  Stream<List<domain.RecurringTransaction>> watchRecurringList() {
    return recurringDao.watchAllRecurring().map(
      (list) => list.map(_mapToEntity).toList(),
    );
  }

  @override
  Future<List<domain.RecurringTransaction>> getDueRecurring() async {
    final results = await recurringDao.getDueRecurring();

    return results.map(_mapToEntity).toList();
  }

  RecurringTransactionsCompanion _toCompanion(
    domain.RecurringTransaction recurring,
  ) {
    final id = recurring.id;
    if (id == null) {
      throw ArgumentError('RecurringTransaction id must not be null');
    }

    return RecurringTransactionsCompanion(
      id: Value(id),
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
    );
  }

  domain.RecurringTransaction _mapToEntity(RecurringTransaction r) {
    return domain.RecurringTransaction(
      id: r.id,
      description: r.description,
      amount: r.amount,
      categoryId: r.categoryId,
      frequency: domain.RecurringFrequency.values.firstWhere(
        (f) => f.name == r.frequency,
        orElse: () => domain.RecurringFrequency.monthly,
      ),
      startDate: r.startDate,
      endDate: r.endDate,
      nextOccurrence: r.nextOccurrence,
      isActive: r.isActive,
      autoCreateExpense: r.autoCreateExpense,
      dayOfMonth: r.dayOfMonth,
    );
  }
}
