import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/incoming_sms_event.dart';
import 'package:expense_tracker/features/sms_parser/domain/services/realtime_sms_listener.dart';
import 'package:expense_tracker/features/sms_parser/domain/services/sms_sender_normalizer.dart';

class RealtimeSmsProcessor {
  final RealtimeSmsListener _listener;
  final EvaluateRulesUseCase _evaluateRules;
  final ParsingIsolateService _parsingIsolateService;
  final RecordRepository _recordRepository;
  final CreateRecordsFromParsedList _createRecordsFromParsedList;

  StreamSubscription<IncomingSmsEvent>? _subscription;
  Future<void> _processingChain = Future<void>.value();
  bool _isStarted = false;

  RealtimeSmsProcessor({
    required RealtimeSmsListener listener,
    required EvaluateRulesUseCase evaluateRules,
    required ParsingIsolateService parsingIsolateService,
    required RecordRepository recordRepository,
    required CreateRecordsFromParsedList createRecordsFromParsedList,
  }) : _listener = listener,
       _evaluateRules = evaluateRules,
       _parsingIsolateService = parsingIsolateService,
       _recordRepository = recordRepository,
       _createRecordsFromParsedList = createRecordsFromParsedList;

  Future<void> start() async {
    if (_isStarted) {
      return;
    }
    _isStarted = true;

    var listenerStarted = false;
    try {
      await _listener.start();
      listenerStarted = true;

      await drainPendingMessages();

      _subscription = _listener.messages.listen(
        (event) {
          unawaited(_enqueueProcessing(event));
        },
        onError: (Object error, StackTrace stackTrace) {
          _logError('stream error', error, stackTrace);
        },
      );
    } catch (_) {
      _isStarted = false;
      await _subscription?.cancel();
      _subscription = null;
      if (listenerStarted) {
        await _listener.stop();
      }
      rethrow;
    }
  }

  Future<void> drainPendingMessages() async {
    final pendingEvents = await _listener.drainPendingMessages();
    for (final event in pendingEvents) {
      await _enqueueProcessing(event);
    }
  }

  Future<void> stop() async {
    _isStarted = false;
    await _subscription?.cancel();
    _subscription = null;
    await _listener.stop();
  }

  Future<void> _enqueueProcessing(IncomingSmsEvent event) {
    _processingChain = _processingChain.then((_) => _processEvent(event));
    return _processingChain;
  }

  Future<void> _processEvent(IncomingSmsEvent event) async {
    try {
      final context = await _evaluateRules.loadContext();
      final monitoredSources = context.sources.where((s) => s.isMonitored);

      if (!_isMonitoredSender(event.address, monitoredSources)) {
        return;
      }

      final parsedResults = await _parsingIsolateService.parseMessages(
        messages: [
          ParseMessageInput(
            body: event.body,
            address: event.address,
            date: event.receivedAt,
            sourceId: event.sourceId,
          ),
        ],
        context: context,
        sourceType: AppSourceType.sms,
      );

      if (parsedResults.isEmpty) {
        return;
      }

      final sourceIds = parsedResults.map((result) => result.sourceId).toList();
      final existingIdsResult = await _recordRepository.getExistingSourceIds(
        sourceIds,
      );
      final existingIds = existingIdsResult.fold((failure) {
        _logError('source-id dedupe failed', failure, null);
        return null;
      }, (ids) => ids);

      if (existingIds == null) {
        return;
      }

      final nonDuplicateResults = parsedResults
          .where((result) => !existingIds.contains(result.sourceId))
          .toList();

      if (nonDuplicateResults.isEmpty) {
        return;
      }

      await _createRecordsFromParsedList(nonDuplicateResults);
    } catch (error, stackTrace) {
      _logError('event processing failed', error, stackTrace);
      return;
    }
  }

  void _logError(String message, Object error, StackTrace? stackTrace) {
    debugPrint('RealtimeSmsProcessor: $message: $error');
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }

  bool _isMonitoredSender(String sender, Iterable<MessageSource> sources) {
    final normalizedSender = SmsSenderNormalizer.normalize(sender);

    for (final source in sources) {
      if (SmsSenderNormalizer.normalize(source.contactId) == normalizedSender) {
        return true;
      }
    }

    return false;
  }
}
