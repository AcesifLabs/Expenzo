import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../../parsing_rules/domain/services/parsing_isolate_service.dart';
import '../../../parsing_rules/domain/entities/parsing_context.dart';
import '../../../parsing_rules/domain/usecases/evaluate_rules_use_case.dart'
    as eval;
import '../../../message_templates/domain/entities/message_source.dart';
import '../../data/datasources/sms_local_datasource.dart';
import '../entities/sms_scan_page.dart';
import '../entities/sms_scan_result_item.dart';
import '../entities/sms_message.dart';

const _minimumRawBatchSize = 50;

class ScanSmsUseCase implements UseCase<SmsScanPage, ScanSmsParams> {
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
  Future<Either<Failure, SmsScanPage>> call(ScanSmsParams params) async {
    try {
      final context = await evaluateRules.loadContext();
      final monitoredSources = context.sources
          .where((s) => s.isMonitored)
          .toList();

      if (monitoredSources.isEmpty) {
        return const Right(
          SmsScanPage(results: [], nextOffset: 0, hasReachedMax: true),
        );
      }

      return Right(
        await _scanPage(
          params: params,
          monitoredSources: monitoredSources,
          context: context,
        ),
      );
    } catch (e, s) {
      appLogger.error('Scan SMS error', e, s);

      return Left(SmsScanFailure(message: e.toString()));
    }
  }

  Future<SmsScanPage> _scanPage({
    required ScanSmsParams params,
    required List<MessageSource> monitoredSources,
    required ParsingContext context,
  }) async {
    final limit = params.limit ?? 10;
    final rawBatchSize = math.max(limit, _minimumRawBatchSize);
    final monitoredSourceByAddress = {
      for (final source in monitoredSources) source.contactId: source,
    };
    final startDate = _startOfDay(params.startDate);
    final endDate = _endOfDay(params.endDate);

    var nextOffset = params.offset ?? 0;
    var hasReachedMax = false;
    final collected = <SmsScanResultItem>[];

    while (collected.length < limit && !hasReachedMax) {
      final rawMessages = await smsDatasource.getSmsBatched(
        start: nextOffset,
        count: rawBatchSize,
      );

      if (rawMessages.isEmpty) {
        hasReachedMax = true;
        break;
      }

      final batchResult = await _consumeBatch(
        _BatchConsumptionParams(
          rawMessages: rawMessages,
          monitoredSourceByAddress: monitoredSourceByAddress,
          context: context,
          startDate: startDate,
          endDate: endDate,
          remainingSlots: limit - collected.length,
        ),
      );

      collected.addAll(batchResult.items);
      nextOffset += batchResult.consumedRawMessages;

      final exhaustedFetchedMessages =
          rawMessages.length < rawBatchSize &&
          batchResult.consumedRawMessages >= rawMessages.length;

      if (batchResult.reachedStartBoundary ||
          batchResult.filledRequestedSlots ||
          rawMessages.length < rawBatchSize) {
        hasReachedMax =
            batchResult.reachedStartBoundary || exhaustedFetchedMessages;
      }
    }

    return SmsScanPage(
      results: collected,
      nextOffset: nextOffset,
      hasReachedMax: hasReachedMax,
    );
  }

  Future<_BatchConsumptionResult> _consumeBatch(
    _BatchConsumptionParams params,
  ) async {
    final parseInputs = <ParseMessageInput>[];

    for (final message in params.rawMessages) {
      if (_isOlderThanStart(message.date, params.startDate)) {
        break;
      }

      if (_shouldParseMessage(
        message: message,
        monitoredSourceByAddress: params.monitoredSourceByAddress,
        startDate: params.startDate,
        endDate: params.endDate,
      )) {
        parseInputs.add(
          ParseMessageInput(
            body: message.body,
            address: message.address,
            date: message.date,
            sourceId: _generateSourceId(message),
          ),
        );
      }
    }

    final parsedResults = await _isolateService.parseMessages(
      messages: parseInputs,
      context: params.context,
      sourceType: ExpenseSource.sms.name,
    );
    final parsedBySourceId = {
      for (final result in parsedResults) result.sourceId: result,
    };

    final items = <SmsScanResultItem>[];
    var consumedRawMessages = 0;
    var reachedStartBoundary = false;
    var filledRequestedSlots = false;

    for (final message in params.rawMessages) {
      if (_isOlderThanStart(message.date, params.startDate)) {
        reachedStartBoundary = true;
        break;
      }

      consumedRawMessages += 1;

      if (!_shouldParseMessage(
        message: message,
        monitoredSourceByAddress: params.monitoredSourceByAddress,
        startDate: params.startDate,
        endDate: params.endDate,
      )) {
        continue;
      }

      final sourceId = _generateSourceId(message);
      final parsed = parsedBySourceId[sourceId];
      if (parsed == null) {
        continue;
      }

      final source = params.monitoredSourceByAddress[message.address];
      items.add(
        SmsScanResultItem(
          parsedTransaction: parsed,
          senderKey: message.address,
          senderLabel: source?.contactName ?? message.address,
        ),
      );

      if (items.length >= params.remainingSlots) {
        filledRequestedSlots = true;
        break;
      }
    }

    if (consumedRawMessages == 0 && params.rawMessages.isNotEmpty) {
      consumedRawMessages = params.rawMessages.length;
    }

    return _BatchConsumptionResult(
      items: items,
      consumedRawMessages: consumedRawMessages,
      reachedStartBoundary: reachedStartBoundary,
      filledRequestedSlots: filledRequestedSlots,
    );
  }

  bool _shouldParseMessage({
    required SmsMessage message,
    required Map<String, MessageSource> monitoredSourceByAddress,
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    if (!monitoredSourceByAddress.containsKey(message.address)) {
      return false;
    }

    if (startDate != null && message.date.isBefore(startDate)) {
      return false;
    }

    if (endDate != null && message.date.isAfter(endDate)) {
      return false;
    }

    return true;
  }

  bool _isOlderThanStart(DateTime date, DateTime? startDate) {
    return startDate != null && date.isBefore(startDate);
  }

  DateTime? _startOfDay(DateTime? date) {
    if (date == null) return null;

    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _endOfDay(DateTime? date) {
    if (date == null) return null;

    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);
  }

  String _generateSourceId(SmsMessage message) {
    final combined = '${message.address}_${message.date.toIso8601String()}';

    return combined.hashCode.abs().toString();
  }
}

class ScanSmsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? offset;
  final int? limit;

  ScanSmsParams({this.startDate, this.endDate, this.offset, this.limit});
}

class SmsScanFailure extends Failure {
  const SmsScanFailure({required super.message})
    : super(errorCode: 'SMS_SCAN_ERROR');
}

class _BatchConsumptionResult {
  final List<SmsScanResultItem> items;
  final int consumedRawMessages;
  final bool reachedStartBoundary;
  final bool filledRequestedSlots;

  const _BatchConsumptionResult({
    required this.items,
    required this.consumedRawMessages,
    required this.reachedStartBoundary,
    required this.filledRequestedSlots,
  });
}

class _BatchConsumptionParams {
  final List<SmsMessage> rawMessages;
  final Map<String, MessageSource> monitoredSourceByAddress;
  final ParsingContext context;
  final DateTime? startDate;
  final DateTime? endDate;
  final int remainingSlots;

  const _BatchConsumptionParams({
    required this.rawMessages,
    required this.monitoredSourceByAddress,
    required this.context,
    required this.startDate,
    required this.endDate,
    required this.remainingSlots,
  });
}
