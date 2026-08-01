import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/receipt_extraction.dart';

abstract class ReceiptScanRepository {
  Future<Either<Failure, ReceiptExtraction>> extractFromImage({
    required Uint8List imageBytes,
    required String mimeType,
    List<String> categoryNames = const [],
  });
}
