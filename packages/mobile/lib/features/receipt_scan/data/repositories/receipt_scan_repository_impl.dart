import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_datasource.dart';
import 'package:expense_tracker/features/ai_assistant/data/datasources/groq_vision_request.dart';
import '../../domain/entities/receipt_extraction.dart';
import '../../domain/repositories/receipt_scan_repository.dart';
import '../receipt_extraction_parser.dart';

class ReceiptScanRepositoryImpl implements ReceiptScanRepository {
  final GroqDataSource dataSource;
  final ReceiptExtractionParser parser;

  String get _userMessage {
    final today = DateTime.now();
    final todayIso =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    return '''
Read this receipt image and reply with a single JSON object only.
Example shape:
{"amount":12.5,"description":"Grocery shopping","date":"$todayIso","category":"Food & Dining"}
No markdown, no commentary.
''';
  }

  ReceiptScanRepositoryImpl({
    required this.dataSource,
    this.parser = const ReceiptExtractionParser(),
  });

  @override
  Future<Either<Failure, ReceiptExtraction>> extractFromImage({
    required Uint8List imageBytes,
    required String mimeType,
    List<String> categoryNames = const [],
  }) async {
    try {
      appLogger.info(
        'ReceiptScan extract start mimeType=$mimeType '
        'bytes=${imageBytes.length} categories=${categoryNames.length}',
      );
      final raw = await dataSource.completeWithImage(
        GroqVisionRequest(
          systemPrompt: _systemPrompt(categoryNames),
          userMessage: _userMessage,
          imageBase64: base64Encode(imageBytes),
          mimeType: mimeType,
        ),
      );

      final extraction = parser.parse(raw);
      appLogger.info(
        'ReceiptScan extract ok amount=${extraction.amount} '
        'description=${extraction.description} date=${extraction.date} '
        'category=${extraction.categoryName}',
      );

      return Right(extraction);
    } on FormatException catch (e, s) {
      appLogger.error('ReceiptScan parse failed: ${e.message}', e, s);

      return Left(ServerFailure(message: e.message));
    } catch (e, s) {
      appLogger.error('ReceiptScan extract failed', e, s);

      return Left(ServerFailure(message: e.toString()));
    }
  }

  String _systemPrompt(List<String> categoryNames) {
    final categoryInstruction = categoryNames.isEmpty
        ? 'category: short expense type label, or null'
        : 'category: exactly one of [${categoryNames.join(', ')}] when one fits, '
              'otherwise null';

    return '''
You are a receipt field extractor.
Output one JSON object with keys:
amount (number, total due; 0 if unreadable),
description (short purchase summary, max 8 words),
date (YYYY-MM-DD from the receipt, or null if unreadable),
$categoryInstruction.
Prefer TOTAL / AMOUNT DUE over subtotal.
Do not invent a date from the example — use the receipt or null.
''';
  }
}
