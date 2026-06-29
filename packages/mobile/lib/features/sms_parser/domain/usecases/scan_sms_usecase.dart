import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import '../../../parsing_rules/domain/services/parsing_isolate_service.dart';
import '../../../parsing_rules/domain/usecases/evaluate_rules_use_case.dart'
    as eval;
import '../../data/datasources/sms_local_datasource.dart';
import '../entities/sms_message.dart';

class ScanSmsUseCase
    implements UseCase<List<ParsedTransaction>, ScanSmsParams> {
  final SmsLocalDatasource smsDatasource;
  final eval.EvaluateRulesUseCase evaluateRules;
  final ParsingIsolateService _isolateService;

  ScanSmsUseCase({
    required this.smsDatasource,
    required this.evaluateRules,
    required ParsingIsolateService parsingIsolateService,
  }) : _isolateService = parsingIsolateService;

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, List<ParsedTransaction>>> call(
    ScanSmsParams params,
  ) async {
    try {
      final offset = params.offset ?? 0;
      final limit = params.limit ?? 10;

      final messages = await smsDatasource.getSmsBatched(
        start: offset,
        count: limit,
      );

      if (messages.isEmpty) {
        return const Right([]);
      }

      List<SmsMessage> filteredMessages = messages;
      final since = params.since;
      if (since != null) {
        filteredMessages = messages
            .where((m) => m.date.isAfter(since))
            .toList();
      }

      final context = await evaluateRules.loadContext();

      final parseInputs = filteredMessages.map((message) {
        return ParseMessageInput(
          body: message.body,
          address: message.address,
          date: message.date,
          sourceId: _generateSourceId(message),
        );
      }).toList();

      final results = await _isolateService.parseMessages(
        messages: parseInputs,
        context: context,
        sourceType: ExpenseSource.sms.name,
      );

      return Right(results);
    } catch (e, s) {
      print('Error: $e\n$s');
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
