import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../repositories/data_wipe_repository.dart';

class DeleteAllData implements UseCase<Unit, NoParams> {
  final DataWipeRepository repository;

  const DeleteAllData(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.deleteAllData();
  }
}
