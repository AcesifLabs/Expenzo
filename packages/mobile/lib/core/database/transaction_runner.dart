import 'app_database.dart';

abstract class TransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}

class DriftTransactionRunner implements TransactionRunner {
  final AppDatabase db;

  DriftTransactionRunner(this.db);

  @override
  Future<T> run<T>(Future<T> Function() action) => db.transaction(action);
}
