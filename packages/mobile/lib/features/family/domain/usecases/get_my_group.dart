import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/cached.dart';
import '../entities/my_group.dart';
import '../repositories/family_repository.dart';

class GetMyGroupParams extends Params {
  /// Return the cached group without a request when there is one.
  final bool preferCache;

  @override
  List<Object?> get props => [preferCache];

  const GetMyGroupParams({this.preferCache = false});
}

class GetMyGroup extends UseCase<Cached<MyGroup?>, GetMyGroupParams> {
  final FamilyRepository repository;

  GetMyGroup(this.repository);

  @override
  Future<Either<Failure, Cached<MyGroup?>>> call(GetMyGroupParams params) =>
      repository.getMyGroup(preferCache: params.preferCache);
}
