import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/export_file.dart';
import '../entities/export_request.dart';
import '../repositories/export_repository.dart';

class ExportData implements UseCase<ExportFile, ExportRequest> {
  final ExportRepository repository;

  const ExportData(this.repository);

  @override
  Future<Either<Failure, ExportFile>> call(ExportRequest request) {
    return repository.export(request);
  }
}

class EmptyExportFailure extends Failure {
  const EmptyExportFailure()
    : super(message: 'No transactions in range', errorCode: 'EXPORT_EMPTY');
}
