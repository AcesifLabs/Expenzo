import 'dart:async';

import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/future_chain.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules_use_case.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/auto_imported_record.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/incoming_sms_event.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/monitored_source.dart';
import 'package:expense_tracker/features/sms_parser/domain/services/realtime_sms_listener.dart';
import 'package:expense_tracker/features/sms_parser/domain/services/sms_sender_normalizer.dart';
import 'package:expense_tracker/features/sms_parser/domain/usecases/notify_auto_imported_records.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';

class RealtimeSmsProcessor {
  final RealtimeSmsListener _listener;
  final EvaluateRulesUseCase _evaluateRules;
  final ParsingIsolateService _parsingIsolateService;
  final RecordRepository _recordRepository;
  final CreateRecordsFromParsedList _createRecordsFromParsedList;
  final CheckBudgetAlerts _checkBudgetAlerts;
  final NotifyAutoImportedRecords _notifyAutoImportedRecords;

  StreamSubscription<IncomingSmsEvent>? _subscription;
  Future<void> _processingChain = Future<void>.value();
  bool _isStarted = false;

  RealtimeSmsProcessor({
    required RealtimeSmsListener listener,
    required EvaluateRulesUseCase evaluateRules,
    required ParsingIsolateService parsingIsolateService,
    required RecordRepository recordRepository,
    required CreateRecordsFromParsedList createRecordsFromParsedList,
    required CheckBudgetAlerts checkBudgetAlerts,
    required NotifyAutoImportedRecords notifyAutoImportedRecords,
  }) : _checkBudgetAlerts = checkBudgetAlerts,
       _notifyAutoImportedRecords = notifyAutoImportedRecords,
       _listener = listener,
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
          unawaited(_processAndNotify(event));
        },
        onError: (Object error, StackTrace stackTrace) {
          _logError('stream error', error, stackTrace);
        },
      );
    } catch (e) {
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
    final imported = <AutoImportedRecord>[];
    for (final event in pendingEvents) {
      imported.addAll(await _enqueueProcessing(event));
    }
    await _afterImport(imported);
  }

  Future<void> stop() async {
    _isStarted = false;
    await _subscription?.cancel();
    _subscription = null;
    await _listener.stop();
  }

  Future<void> _processAndNotify(IncomingSmsEvent event) async {
    await _afterImport(await _enqueueProcessing(event));
  }

  Future<List<AutoImportedRecord>> _enqueueProcessing(IncomingSmsEvent event) {
    final result = _processingChain.then((_) => _processEvent(event));
    _processingChain = result.then(ignoreOutcome, onError: ignoreOutcome);

    return result;
  }

  Future<void> _afterImport(List<AutoImportedRecord> imported) async {
    if (imported.isEmpty) return;

    await _notifyAutoImportedRecords(imported);
    await _checkBudgetAlerts();
  }

  Future<List<AutoImportedRecord>> _processEvent(IncomingSmsEvent event) async {
    try {
      final context = await _evaluateRules.loadContext();
      final monitoredSources = context.sources
          .where((s) => s.isMonitored)
          .map((s) => MonitoredSource(contactId: s.contactId));

      if (!_isMonitoredSender(event.address, monitoredSources)) {
        return const [];
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
        return const [];
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
        return const [];
      }

      final nonDuplicateResults = parsedResults
          .where((result) => !existingIds.contains(result.sourceId))
          .toList();

      if (nonDuplicateResults.isEmpty) {
        return const [];
      }

      final created = await _createRecordsFromParsedList(nonDuplicateResults);

      return created.fold(
        (failure) {
          _logError('record creation failed', failure, null);

          return const [];
        },
        (result) {
          if (result.createdCount == 0) return const [];

          return _importedFrom(nonDuplicateResults, event.address);
        },
      );
    } catch (error, stackTrace) {
      _logError('event processing failed', error, stackTrace);

      return const [];
    }
  }

  List<AutoImportedRecord> _importedFrom(
    List<ParsedTransaction> results,
    String sender,
  ) {
    return [
      for (final result in results)
        if (result.amount case final amount? when amount > 0)
          AutoImportedRecord(
            sourceId: result.sourceId,
            amount: amount,
            description: result.description,
            sender: sender.trim(),
            recordType: RecordType.expense,
          ),
    ];
  }

  void _logError(String message, Object error, StackTrace? stackTrace) {
    appLogger.error(message, error, stackTrace);
  }

  bool _isMonitoredSender(String sender, Iterable<MonitoredSource> sources) {
    final normalizedSender = SmsSenderNormalizer.normalize(sender);

    for (final source in sources) {
      if (SmsSenderNormalizer.normalize(source.contactId) == normalizedSender) {
        return true;
      }
    }

    return false;
  }
}
