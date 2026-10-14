import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/export_file.dart';
import '../entities/export_request.dart';

abstract class ExportRepository {
  Future<Either<Failure, ExportFile>> export(ExportRequest request);
}
