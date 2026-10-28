import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/sync_overview.dart';
import '../repositories/sync_overview_repository.dart';

class GetSyncOverview implements UseCase<SyncOverview, NoParams> {
  final SyncOverviewRepository repository;

  const GetSyncOverview(this.repository);

  @override
  Future<Either<Failure, SyncOverview>> call(NoParams params) {
    return repository.getOverview();
  }
}
