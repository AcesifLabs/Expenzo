import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/receipt_extraction.dart';
import '../repositories/receipt_scan_repository.dart';

class ExtractReceipt extends UseCase<ReceiptExtraction, ExtractReceiptParams> {
  final ReceiptScanRepository repository;

  ExtractReceipt(this.repository);

  @override
  Future<Either<Failure, ReceiptExtraction>> call(ExtractReceiptParams params) {
    return repository.extractFromImage(
      imageBytes: params.imageBytes,
      mimeType: params.mimeType,
      categoryNames: params.categoryNames,
    );
  }
}

class ExtractReceiptParams extends Params {
  final Uint8List imageBytes;
  final String mimeType;
  final List<String> categoryNames;

  @override
  List<Object?> get props => [imageBytes, mimeType, categoryNames];

  const ExtractReceiptParams({
    required this.imageBytes,
    required this.mimeType,
    this.categoryNames = const [],
  });
}

class ReceiptTotalUnreadableFailure extends Failure {
  const ReceiptTotalUnreadableFailure({
    super.message = 'Receipt total is unreadable',
    super.errorCode = 'RECEIPT_TOTAL_UNREADABLE',
  });
}

class ReceiptServiceUnavailableFailure extends Failure {
  const ReceiptServiceUnavailableFailure({
    required super.message,
    super.errorCode = 'RECEIPT_SERVICE_UNAVAILABLE',
  });
}
