import '../../../../core/database/daos/recurring_dao.dart';
import '../../domain/entities/recurring_transaction.dart' as domain;

abstract class RecurringLocalDatasource {
  Future<List<domain.RecurringTransaction>> getRecurringList();
  Future<domain.RecurringTransaction?> getRecurringById(String id);
  Future<void> createRecurring(domain.RecurringTransaction recurring);
  Future<void> updateRecurring(domain.RecurringTransaction recurring);
  Future<void> deleteRecurring(String id);
  Stream<List<domain.RecurringTransaction>> watchRecurringList();
  Future<List<domain.RecurringTransaction>> getDueRecurring();
}

class RecurringLocalDatasourceImpl implements RecurringLocalDatasource {
  final RecurringDao recurringDao;

  RecurringLocalDatasourceImpl({required this.recurringDao});

  @override
  Future<List<domain.RecurringTransaction>> getRecurringList() async {
    return recurringDao.getAllRecurring();
  }

  @override
  Future<domain.RecurringTransaction?> getRecurringById(String id) async {
    return recurringDao.getRecurringById(id);
  }

  @override
  Future<void> createRecurring(domain.RecurringTransaction recurring) async {
    await recurringDao.insertRecurring(recurring);
  }

  @override
  Future<void> updateRecurring(domain.RecurringTransaction recurring) async {
    await recurringDao.updateRecurring(recurring);
  }

  @override
  Future<void> deleteRecurring(String id) async {
    await recurringDao.deleteRecurring(id);
  }

  @override
  Stream<List<domain.RecurringTransaction>> watchRecurringList() {
    return recurringDao.watchAllRecurring();
  }

  @override
  Future<List<domain.RecurringTransaction>> getDueRecurring() async {
    return recurringDao.getDueRecurring();
  }
}
