import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../../domain/entities/export_file.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/repositories/export_repository.dart';
import '../../domain/usecases/export_data.dart';
import '../datasources/export_local_datasource.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportLocalDatasource localDatasource;

  /// The time the range is resolved against.
  final DateTime Function() clock;

  const ExportRepositoryImpl({
    required this.localDatasource,
    this.clock = DateTime.now,
  });

  @override
  Future<Either<Failure, ExportFile>> export(ExportRequest request) async {
    try {
      return Right(await localDatasource.export(request, clock()));
    } on EmptyExportException {
      return const Left(EmptyExportFailure());
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }
}
