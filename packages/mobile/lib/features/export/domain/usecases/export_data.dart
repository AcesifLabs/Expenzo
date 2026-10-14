import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/export_file.dart';
import '../entities/export_request.dart';
import '../repositories/export_repository.dart';

/// Writes the requested export and returns the file to share.
class ExportData implements UseCase<ExportFile, ExportRequest> {
  final ExportRepository repository;

  const ExportData(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, ExportFile>> call(ExportRequest request) {
    return repository.export(request);
  }
}

/// Transactions were requested but none fall in the range. The message is
/// for logs; the screen shows its own text.
class EmptyExportFailure extends Failure {
  const EmptyExportFailure()
    : super(message: 'No transactions in range', errorCode: 'EXPORT_EMPTY');
}
