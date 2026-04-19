import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import '../../../parsing_rules/domain/usecases/evaluate_rules.dart' as eval;
import '../../data/datasources/sms_local_datasource.dart';
import '../entities/sms_message.dart';

class ScanSmsUseCase
    implements UseCase<List<ParsedTransaction>, ScanSmsParams> {
  final SmsLocalDatasource smsDatasource;
  final eval.EvaluateRulesUseCase evaluateRules;

  ScanSmsUseCase({required this.smsDatasource, required this.evaluateRules});

  @override
  Future<Either<Failure, List<ParsedTransaction>>> call(
    ScanSmsParams params,
  ) async {
    try {
      final since =
          params.since ?? DateTime.now().subtract(const Duration(days: 7));

      // Get all SMS from the last 7 days
      final messages = await smsDatasource.getSmsFromDateRange(
        since,
        DateTime.now(),
      );

      if (messages.isEmpty) {
        return const Right([]);
      }

      final List<ParsedTransaction> results = [];
      final processedIds = <String>{};

      for (final message in messages) {
        // Create unique source ID
        final sourceId = _generateSourceId(message);

        // Skip duplicates
        if (processedIds.contains(sourceId)) continue;
        processedIds.add(sourceId);

        // Evaluate rules
        final result = await evaluateRules(
          eval.EvaluateRulesParams(
            rawMessage: message.body,
            sourceType: 'sms',
            sourceId: sourceId,
            address: message.address,
            messageDate: message.date,
          ),
        );

        result.fold(
          (failure) {
            // Skip on failure
          },
          (parsed) {
            if (parsed != null &&
                !parsed.parseFailed &&
                parsed.amount != null) {
              results.add(parsed);
            }
          },
        );
      }

      // Sort by confidence (highest first)
      results.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

      return Right(results);
    } catch (e) {
      return Left(SmsScanFailure(message: e.toString()));
    }
  }

  String _generateSourceId(SmsMessage message) {
    final combined = '${message.address}_${message.date.toIso8601String()}';
    return combined.hashCode.abs().toString();
  }
}

class ScanSmsParams {
  final DateTime? since;

  ScanSmsParams({this.since});
}

class SmsScanFailure extends Failure {
  const SmsScanFailure({required super.message})
    : super(errorCode: 'SMS_SCAN_ERROR');
}
