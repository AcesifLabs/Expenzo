import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recurring_transaction.dart';

abstract class RecurringRepository {
  Future<Either<Failure, List<RecurringTransaction>>> getRecurringList();
  Future<Either<Failure, RecurringTransaction>> getRecurringById(String id);
  Future<Either<Failure, RecurringTransaction>> createRecurring(
    RecurringTransaction recurring,
  );
  Future<Either<Failure, RecurringTransaction>> updateRecurring(
    RecurringTransaction recurring,
  );
  Future<Either<Failure, Unit>> deleteRecurring(String id);
  Stream<List<RecurringTransaction>> watchRecurringList();
  Future<Either<Failure, List<RecurringTransaction>>> getDueRecurring();
}
