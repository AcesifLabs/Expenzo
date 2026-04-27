import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import '../../../parsing_rules/domain/services/parsing_isolate_service.dart';
import '../../../parsing_rules/domain/usecases/evaluate_rules.dart' as eval;
import '../../data/datasources/sms_local_datasource.dart';
import '../entities/sms_message.dart';

class ScanSmsUseCase
    implements UseCase<List<ParsedTransaction>, ScanSmsParams> {
  final SmsLocalDatasource smsDatasource;
  final eval.EvaluateRulesUseCase evaluateRules;
  final ParsingIsolateService _isolateService = ParsingIsolateService();

  ScanSmsUseCase({required this.smsDatasource, required this.evaluateRules});

  @override
  Future<Either<Failure, List<ParsedTransaction>>> call(
    ScanSmsParams params,
  ) async {
    try {
      final offset = params.offset ?? 0;
      final limit = params.limit ?? 10;

      // Fetch a paginated batch of SMS messages
      final messages = await smsDatasource.getSmsBatched(
        start: offset,
        count: limit,
      );

      if (messages.isEmpty) {
        return const Right([]);
      }

      // Filter messages by the 'since' date
      List<SmsMessage> filteredMessages = messages;
      if (params.since != null) {
        filteredMessages = messages
            .where((m) => m.date.isAfter(params.since!))
            .toList();
      }

      // Pre-fetch ALL rules, templates, and sources ONCE (was N queries, now 3)
      final context = await evaluateRules.loadContext();

      // Prepare lightweight input objects for the isolate
      final parseInputs = filteredMessages.map((message) {
        return ParseMessageInput(
          body: message.body,
          address: message.address,
          date: message.date,
          sourceId: _generateSourceId(message),
        );
      }).toList();

      // Offload heavy parsing to background isolate — keeps UI responsive
      final results = await _isolateService.parseMessages(
        messages: parseInputs,
        context: context,
        sourceType: 'sms',
      );

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
  final int? offset;
  final int? limit;

  ScanSmsParams({this.since, this.offset, this.limit});
}

class SmsScanFailure extends Failure {
  const SmsScanFailure({required super.message})
    : super(errorCode: 'SMS_SCAN_ERROR');
}
