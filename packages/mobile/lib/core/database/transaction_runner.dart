import 'app_database.dart';

/// Runs work that spans several repositories in one database transaction:
/// it all commits, or a throw rolls it all back.
abstract class TransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}

class DriftTransactionRunner implements TransactionRunner {
  final AppDatabase db;

  DriftTransactionRunner(this.db);

  @override
  Future<T> run<T>(Future<T> Function() action) => db.transaction(action);
}
