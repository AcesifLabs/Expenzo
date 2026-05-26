import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_types.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'package:expense_tracker/features/sms_parser/application/realtime_sms_processor.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/incoming_sms_event.dart';
import 'package:expense_tracker/features/sms_parser/domain/services/realtime_sms_listener.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRealtimeSmsListener extends Mock implements RealtimeSmsListener {}

class MockEvaluateRulesUseCase extends Mock implements EvaluateRulesUseCase {}

class MockParsingIsolateService extends Mock implements ParsingIsolateService {}

class MockRecordRepository extends Mock implements RecordRepository {}

class MockCreateRecordsFromParsedList extends Mock
    implements CreateRecordsFromParsedList {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ParsingContext(rules: [], templates: [], sources: []),
    );
  });

  late MockRealtimeSmsListener listener;
  late MockEvaluateRulesUseCase evaluateRules;
  late MockParsingIsolateService parsingIsolateService;
  late MockRecordRepository recordRepository;
  late MockCreateRecordsFromParsedList createRecordsFromParsedList;
  late StreamController<IncomingSmsEvent> streamController;
  late RealtimeSmsProcessor processor;

  final monitoredSource = MessageSource(
    id: 'source-1',
    contactId: 'VK-BANK',
    contactName: 'VK-BANK',
    isMonitored: true,
    createdAt: DateTime.parse('2026-05-26T10:00:00Z'),
    updatedAt: DateTime.parse('2026-05-26T10:00:00Z'),
  );

  setUp(() {
    listener = MockRealtimeSmsListener();
    evaluateRules = MockEvaluateRulesUseCase();
    parsingIsolateService = MockParsingIsolateService();
    recordRepository = MockRecordRepository();
    createRecordsFromParsedList = MockCreateRecordsFromParsedList();
    streamController = StreamController<IncomingSmsEvent>.broadcast();

    when(() => listener.start()).thenAnswer((_) async {});
    when(() => listener.stop()).thenAnswer((_) async {});
    when(() => listener.messages).thenAnswer((_) => streamController.stream);
    when(() => listener.drainPendingMessages()).thenAnswer((_) async => []);

    processor = RealtimeSmsProcessor(
      listener: listener,
      evaluateRules: evaluateRules,
      parsingIsolateService: parsingIsolateService,
      recordRepository: recordRepository,
      createRecordsFromParsedList: createRecordsFromParsedList,
    );
  });

  tearDown(() async {
    await processor.stop();
    await streamController.close();
  });

  test('non-monitored sender ignored', () async {
    final contextLoaded = Completer<void>();
    when(
      () => evaluateRules.loadContext(),
    ).thenAnswer((_) async {
      if (!contextLoaded.isCompleted) {
        contextLoaded.complete();
      }
      return ParsingContext(rules: [], templates: [], sources: []);
    });

    await processor.start();

    streamController.add(
      IncomingSmsEvent(
        address: 'AX-FOO',
        body: 'debited 100',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      ),
    );

    await contextLoaded.future;

    verifyNever(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    );
    verifyNever(() => createRecordsFromParsedList(any()));
  });

  test('monitored sender with parse result creates one record', () async {
    final event = IncomingSmsEvent(
      address: ' vk-bank ',
      body: 'debited 120',
      receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
    );
    final parsed = ParsedTransaction(
      rawMessage: event.body,
      amount: 120,
      date: event.receivedAt,
      description: 'Debited',
      categoryId: 'cat-1',
      sourceType: 'sms',
      sourceId: event.sourceId,
      confidenceScore: 0.95,
      matchedRuleId: 'rule-1',
      parseFailed: false,
    );

    when(() => evaluateRules.loadContext()).thenAnswer(
      (_) async => ParsingContext(
        rules: [],
        templates: [],
        sources: [monitoredSource],
      ),
    );
    when(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    ).thenAnswer((_) async => [parsed]);
    when(
      () => recordRepository.getExistingSourceIds(any()),
    ).thenAnswer((_) async => const Right(<String>{}));
    when(
      () => createRecordsFromParsedList(any()),
    ).thenAnswer((_) async => const Right(CreateRecordsResult(createdCount: 1, skippedDuplicates: 0, errors: [])));

    when(() => listener.drainPendingMessages()).thenAnswer((_) async => [event]);

    await processor.start();

    verify(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: 'sms',
      ),
    ).called(1);
    verify(() => createRecordsFromParsedList(any(that: hasLength(1)))).called(1);
  });

  test('duplicate sourceId ignored', () async {
    final event = IncomingSmsEvent(
      address: 'VK-BANK',
      body: 'debited 120',
      receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
    );
    final parsed = ParsedTransaction(
      rawMessage: event.body,
      amount: 120,
      date: event.receivedAt,
      description: 'Debited',
      categoryId: 'cat-1',
      sourceType: 'sms',
      sourceId: event.sourceId,
      confidenceScore: 0.95,
      matchedRuleId: 'rule-1',
      parseFailed: false,
    );

    when(() => evaluateRules.loadContext()).thenAnswer(
      (_) async => ParsingContext(
        rules: [],
        templates: [],
        sources: [monitoredSource],
      ),
    );
    when(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    ).thenAnswer((_) async => [parsed]);
    when(
      () => recordRepository.getExistingSourceIds(any()),
    ).thenAnswer((_) async => Right(<String>{event.sourceId}));

    when(() => listener.drainPendingMessages()).thenAnswer((_) async => [event]);

    await processor.start();

    verifyNever(() => createRecordsFromParsedList(any()));
  });

  test('only monitored sources are parsed from pending batch', () async {
    final monitoredEvent = IncomingSmsEvent(
      address: ' VK-BANK ',
      body: 'debited 120',
      receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
    );
    final unmonitoredEvent = IncomingSmsEvent(
      address: 'AX-FOO',
      body: 'debited 200',
      receivedAt: DateTime.parse('2026-05-26T11:00:00Z'),
    );

    when(() => evaluateRules.loadContext()).thenAnswer(
      (_) async => ParsingContext(
        rules: [],
        templates: [],
        sources: [monitoredSource],
      ),
    );
    ParseMessageInput? capturedInput;
    when(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    ).thenAnswer((invocation) async {
      final messages = invocation.namedArguments[#messages] as List<ParseMessageInput>;
      capturedInput = messages.first;
      return [];
    });
    when(
      () => listener.drainPendingMessages(),
    ).thenAnswer((_) async => [monitoredEvent, unmonitoredEvent]);

    await processor.start();

    verify(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: 'sms',
      ),
    ).called(1);
    expect(capturedInput?.address, ' VK-BANK ');
    expect(capturedInput?.body, 'debited 120');
  });

  test('dedupe keeps non-duplicate parsed entries only', () async {
    final event = IncomingSmsEvent(
      address: 'VK-BANK',
      body: 'debited 120 and 130',
      receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
    );
    final duplicate = ParsedTransaction(
      rawMessage: event.body,
      amount: 120,
      date: event.receivedAt,
      description: 'Debited first',
      categoryId: 'cat-1',
      sourceType: 'sms',
      sourceId: event.sourceId,
      confidenceScore: 0.95,
      matchedRuleId: 'rule-1',
      parseFailed: false,
    );
    final kept = ParsedTransaction(
      rawMessage: event.body,
      amount: 130,
      date: event.receivedAt,
      description: 'Debited second',
      categoryId: 'cat-1',
      sourceType: 'sms',
      sourceId: '${event.sourceId}-next',
      confidenceScore: 0.92,
      matchedRuleId: 'rule-1',
      parseFailed: false,
    );

    when(() => evaluateRules.loadContext()).thenAnswer(
      (_) async => ParsingContext(
        rules: [],
        templates: [],
        sources: [monitoredSource],
      ),
    );
    when(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    ).thenAnswer((_) async => [duplicate, kept]);
    when(
      () => recordRepository.getExistingSourceIds(any()),
    ).thenAnswer((_) async => Right(<String>{duplicate.sourceId}));
    when(
      () => createRecordsFromParsedList(any()),
    ).thenAnswer((_) async => const Right(CreateRecordsResult(createdCount: 1, skippedDuplicates: 1, errors: [])));
    when(() => listener.drainPendingMessages()).thenAnswer((_) async => [event]);

    await processor.start();

    verify(
      () => createRecordsFromParsedList(
        any(
          that: predicate<List<ParsedTransaction>>(
            (items) =>
                items.length == 1 && items.first.sourceId == kept.sourceId,
          ),
        ),
      ),
    ).called(1);
  });

  test('parse failure does not crash', () async {
    final monitoredEvent = IncomingSmsEvent(
      address: 'VK-BANK',
      body: 'debited 120',
      receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
    );
    final secondEvent = IncomingSmsEvent(
      address: 'VK-BANK',
      body: 'debited 130',
      receivedAt: DateTime.parse('2026-05-26T11:00:00Z'),
    );
    final parsedSecond = ParsedTransaction(
      rawMessage: secondEvent.body,
      amount: 130,
      date: secondEvent.receivedAt,
      description: 'Debited',
      categoryId: 'cat-1',
      sourceType: 'sms',
      sourceId: secondEvent.sourceId,
      confidenceScore: 0.91,
      matchedRuleId: 'rule-1',
      parseFailed: false,
    );

    when(() => evaluateRules.loadContext()).thenAnswer(
      (_) async => ParsingContext(
        rules: [],
        templates: [],
        sources: [monitoredSource],
      ),
    );

    var callCount = 0;
    when(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    ).thenAnswer((_) async {
      callCount += 1;
      if (callCount == 1) {
        throw Exception('parse failed');
      }
      return [parsedSecond];
    });

    when(
      () => recordRepository.getExistingSourceIds(any()),
    ).thenAnswer((_) async => const Right(<String>{}));
    when(
      () => createRecordsFromParsedList(any()),
    ).thenAnswer((_) async => const Right(CreateRecordsResult(createdCount: 1, skippedDuplicates: 0, errors: [])));

    when(
      () => listener.drainPendingMessages(),
    ).thenAnswer((_) async => [monitoredEvent]);

    final createCalled = Completer<void>();
    when(
      () => createRecordsFromParsedList(any()),
    ).thenAnswer((_) async {
      if (!createCalled.isCompleted) {
        createCalled.complete();
      }
      return const Right(
        CreateRecordsResult(createdCount: 1, skippedDuplicates: 0, errors: []),
      );
    });

    await processor.start();

    streamController.add(secondEvent);
    await createCalled.future;

    expect(callCount, 2);
    verify(() => createRecordsFromParsedList(any(that: hasLength(1)))).called(1);
  });

  test('start twice does not double-subscribe or drain', () async {
    final event = IncomingSmsEvent(
      address: 'VK-BANK',
      body: 'debited 99',
      receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
    );
    final parsed = ParsedTransaction(
      rawMessage: event.body,
      amount: 99,
      date: event.receivedAt,
      description: 'Debited',
      categoryId: 'cat-1',
      sourceType: 'sms',
      sourceId: event.sourceId,
      confidenceScore: 0.9,
      matchedRuleId: 'rule-1',
      parseFailed: false,
    );
    final createCalled = Completer<void>();

    when(() => evaluateRules.loadContext()).thenAnswer(
      (_) async => ParsingContext(
        rules: [],
        templates: [],
        sources: [monitoredSource],
      ),
    );
    when(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    ).thenAnswer((_) async => [parsed]);
    when(
      () => recordRepository.getExistingSourceIds(any()),
    ).thenAnswer((_) async => const Right(<String>{}));
    when(
      () => createRecordsFromParsedList(any()),
    ).thenAnswer((_) async {
      if (!createCalled.isCompleted) {
        createCalled.complete();
      }
      return const Right(
        CreateRecordsResult(createdCount: 1, skippedDuplicates: 0, errors: []),
      );
    });

    await processor.start();
    await processor.start();

    streamController.add(event);
    await createCalled.future;

    verify(() => listener.start()).called(1);
    verify(() => listener.drainPendingMessages()).called(1);
    verify(() => createRecordsFromParsedList(any(that: hasLength(1)))).called(1);
  });

  test('stop stops further processing', () async {
    final event = IncomingSmsEvent(
      address: 'VK-BANK',
      body: 'debited 77',
      receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
    );

    when(() => evaluateRules.loadContext()).thenAnswer(
      (_) async => ParsingContext(
        rules: [],
        templates: [],
        sources: [monitoredSource],
      ),
    );
    when(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    ).thenAnswer((_) async => []);

    await processor.start();
    await processor.stop();

    streamController.add(event);

    verifyNever(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    );
  });

  test('getExistingSourceIds Left does not create records', () async {
    final event = IncomingSmsEvent(
      address: 'VK-BANK',
      body: 'debited 120',
      receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
    );
    final parsed = ParsedTransaction(
      rawMessage: event.body,
      amount: 120,
      date: event.receivedAt,
      description: 'Debited',
      categoryId: 'cat-1',
      sourceType: 'sms',
      sourceId: event.sourceId,
      confidenceScore: 0.95,
      matchedRuleId: 'rule-1',
      parseFailed: false,
    );

    when(() => evaluateRules.loadContext()).thenAnswer(
      (_) async => ParsingContext(
        rules: [],
        templates: [],
        sources: [monitoredSource],
      ),
    );
    when(
      () => parsingIsolateService.parseMessages(
        messages: any(named: 'messages'),
        context: any(named: 'context'),
        sourceType: any(named: 'sourceType'),
      ),
    ).thenAnswer((_) async => [parsed]);
    when(
      () => recordRepository.getExistingSourceIds(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db failed')));
    when(() => listener.drainPendingMessages()).thenAnswer((_) async => [event]);

    await processor.start();

    verifyNever(() => createRecordsFromParsedList(any()));
  });

  test('start failure in listener.start resets state and allows retry', () async {
    when(() => listener.start()).thenThrow(Exception('listener failed'));

    await expectLater(processor.start(), throwsException);

    when(() => listener.start()).thenAnswer((_) async {});
    await processor.start();

    verify(() => listener.start()).called(2);
  });

  test('start failure in drainPendingMessages resets state and allows retry', () async {
    when(() => listener.start()).thenAnswer((_) async {});
    when(() => listener.stop()).thenAnswer((_) async {});
    when(
      () => listener.drainPendingMessages(),
    ).thenThrow(Exception('drain failed'));

    await expectLater(processor.start(), throwsException);
    verify(() => listener.stop()).called(1);

    when(() => listener.drainPendingMessages()).thenAnswer((_) async => []);
    await processor.start();

    verify(() => listener.start()).called(2);
  });
}
