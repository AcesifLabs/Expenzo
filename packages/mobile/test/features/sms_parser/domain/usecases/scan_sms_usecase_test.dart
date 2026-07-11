import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/parsing_isolate_service.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules_use_case.dart';
import 'package:expense_tracker/features/sms_parser/data/datasources/sms_local_datasource.dart';
import 'package:expense_tracker/features/sms_parser/domain/usecases/scan_sms_usecase.dart';
import '../../../../support/factories/parsed_transaction_factory.dart';
import '../../../../support/factories/sms_message_factory.dart';

class MockSmsLocalDatasource extends Mock implements SmsLocalDatasource {}

class MockEvaluateRulesUseCase extends Mock implements EvaluateRulesUseCase {}

class MockParsingIsolateService extends Mock implements ParsingIsolateService {}

void main() {
  late MockSmsLocalDatasource mockSmsLocalDatasource;
  late MockEvaluateRulesUseCase mockEvaluateRulesUseCase;
  late MockParsingIsolateService mockParsingIsolateService;
  late ScanSmsUseCase useCase;

  final monitoredSource = MessageSource(
    id: 'source-1',
    contactId: 'BANK',
    contactName: 'City Bank',
    isMonitored: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final context = ParsingContext(
    rules: const [],
    templates: const [],
    sources: [monitoredSource],
  );

  setUpAll(() {
    registerFallbackValue(const <ParseMessageInput>[]);
    registerFallbackValue(
      const ParsingContext(rules: [], templates: [], sources: []),
    );
  });

  setUp(() {
    mockSmsLocalDatasource = MockSmsLocalDatasource();
    mockEvaluateRulesUseCase = MockEvaluateRulesUseCase();
    mockParsingIsolateService = MockParsingIsolateService();
    useCase = ScanSmsUseCase(
      smsDatasource: mockSmsLocalDatasource,
      evaluateRules: mockEvaluateRulesUseCase,
      parsingIsolateService: mockParsingIsolateService,
    );

    when(
      () => mockEvaluateRulesUseCase.loadContext(),
    ).thenAnswer((_) async => context);
  });

  group('monitored sender filtering', () {
    test(
      'parses only monitored senders and keeps display label metadata',
      () async {
        when(
          () => mockSmsLocalDatasource.getSmsBatched(start: 0, count: 50),
        ).thenAnswer(
          (_) async => [
            makeSmsMessage(address: 'BANK', body: 'bank debit 250'),
            makeSmsMessage(
              address: 'SPAM',
              body: 'spam debit 999',
              id: 'sms-2',
            ),
          ],
        );
        when(
          () => mockParsingIsolateService.parseMessages(
            messages: any(named: 'messages'),
            context: any(named: 'context'),
            sourceType: any(named: 'sourceType'),
          ),
        ).thenAnswer(
          (_) async => [
            makeParsedTransaction(
              sourceId: _sourceIdFor('BANK', DateTime(2024, 6, 15, 14, 30)),
            ),
          ],
        );

        final result = await useCase(ScanSmsParams(limit: 10));

        expect(result.isRight(), true);
        final page = result.getOrElse(
          () => throw StateError('expected right result'),
        );
        expect(page.results, hasLength(1));
        expect(page.results.single.senderKey, 'BANK');
        expect(page.results.single.senderLabel, 'City Bank');

        final capturedInputs =
            verify(
                  () => mockParsingIsolateService.parseMessages(
                    messages: captureAny(named: 'messages'),
                    context: context,
                    sourceType: AppSourceType.sms,
                  ),
                ).captured.single
                as List<ParseMessageInput>;
        expect(capturedInputs.map((input) => input.address), ['BANK']);
      },
    );
  });

  group('inclusive date range filtering', () {
    test('includes same-day messages from start to end of day', () async {
      when(
        () => mockSmsLocalDatasource.getSmsBatched(start: 0, count: 50),
      ).thenAnswer(
        (_) async => [
          makeSmsMessage(
            address: 'BANK',
            date: DateTime(2026, 7, 11, 23, 59),
            id: 'sms-1',
          ),
          makeSmsMessage(
            address: 'BANK',
            date: DateTime(2026, 7, 11, 0, 0),
            id: 'sms-2',
          ),
          makeSmsMessage(
            address: 'BANK',
            date: DateTime(2026, 7, 12, 0, 0),
            id: 'sms-3',
          ),
        ],
      );
      when(
        () => mockParsingIsolateService.parseMessages(
          messages: any(named: 'messages'),
          context: any(named: 'context'),
          sourceType: any(named: 'sourceType'),
        ),
      ).thenAnswer(
        (_) async => [
          makeParsedTransaction(
            sourceId: _sourceIdFor('BANK', DateTime(2026, 7, 11, 23, 59)),
          ),
          makeParsedTransaction(
            sourceId: _sourceIdFor('BANK', DateTime(2026, 7, 11, 0, 0)),
          ),
        ],
      );

      await useCase(
        ScanSmsParams(
          startDate: DateTime(2026, 7, 11),
          endDate: DateTime(2026, 7, 11),
          limit: 10,
        ),
      );

      final capturedInputs =
          verify(
                () => mockParsingIsolateService.parseMessages(
                  messages: captureAny(named: 'messages'),
                  context: context,
                  sourceType: AppSourceType.sms,
                ),
              ).captured.single
              as List<ParseMessageInput>;
      expect(capturedInputs, hasLength(2));
      expect(
        capturedInputs.map((input) => input.date),
        containsAll([
          DateTime(2026, 7, 11, 23, 59),
          DateTime(2026, 7, 11, 0, 0),
        ]),
      );
    });
  });

  group('pagination contract', () {
    test(
      'returns nextOffset at the last consumed raw message when page fills',
      () async {
        when(
          () => mockSmsLocalDatasource.getSmsBatched(start: 0, count: 50),
        ).thenAnswer(
          (_) async => [
            makeSmsMessage(
              address: 'BANK',
              date: DateTime(2026, 7, 11, 10, 0),
              id: 'sms-1',
            ),
            makeSmsMessage(
              address: 'BANK',
              date: DateTime(2026, 7, 10, 10, 0),
              id: 'sms-2',
            ),
            makeSmsMessage(
              address: 'BANK',
              date: DateTime(2026, 7, 9, 10, 0),
              id: 'sms-3',
            ),
          ],
        );
        when(
          () => mockParsingIsolateService.parseMessages(
            messages: any(named: 'messages'),
            context: any(named: 'context'),
            sourceType: any(named: 'sourceType'),
          ),
        ).thenAnswer(
          (_) async => [
            makeParsedTransaction(
              sourceId: _sourceIdFor('BANK', DateTime(2026, 7, 11, 10, 0)),
            ),
            makeParsedTransaction(
              sourceId: _sourceIdFor('BANK', DateTime(2026, 7, 10, 10, 0)),
            ),
            makeParsedTransaction(
              sourceId: _sourceIdFor('BANK', DateTime(2026, 7, 9, 10, 0)),
            ),
          ],
        );

        final result = await useCase(ScanSmsParams(limit: 2));

        final page = result.getOrElse(
          () => throw StateError('expected right result'),
        );
        expect(page.results, hasLength(2));
        expect(page.nextOffset, 2);
        expect(page.hasReachedMax, false);
      },
    );
  });
}

String _sourceIdFor(String address, DateTime date) {
  final combined = '${address}_${date.toIso8601String()}';

  return combined.hashCode.abs().toString();
}
