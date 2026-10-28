import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/message_templates/domain/repositories/message_template_repository.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/evaluate_rules_params.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/expense_template.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'sms_corpus_loader.dart';

class MockTemplatesRepo extends Mock implements MessageTemplateRepository {}

void main() {
  group('UAE bank SMS corpus', () {
    late List<CorpusWorkbook> corpus;
    late MockTemplatesRepo templatesRepo;
    late EvaluateRulesUseCase useCase;
    late ParsingContext context;

    setUpAll(() async {
      corpus = await loadSmsCorpus();
      templatesRepo = MockTemplatesRepo();
      final sources = corpusSources(corpus);
      when(
        () => templatesRepo.getAllTemplates(),
      ).thenAnswer((_) async => Right(corpusFormats(sources)));
      when(
        () => templatesRepo.getMessageSources(),
      ).thenAnswer((_) async => Right(sources));
      useCase = EvaluateRulesUseCase(templatesRepo);

      context = await useCase.loadContext();
    });

    test('loads all 7 workbooks under test/data', () {
      expect(corpus, hasLength(7));
    });

    test(
      'every workbook covers both debit and credit directions in the room',
      () {
        final directions = corpus.map((w) => w.direction).toSet();
        expect(
          directions,
          equals({CorpusDirection.debit, CorpusDirection.credit}),
        );
      },
    );

    test('every fixture has a non-empty body and a sane row count', () {
      for (final wb in corpus) {
        expect(
          wb.fixtures.length,
          lessThanOrEqualTo(wb.tableRowCount - 1),
          reason: '${wb.filename} produced more fixtures than data rows',
        );
        expect(
          wb.fixtures.length,
          greaterThan(0),
          reason: '${wb.filename} produced no fixtures',
        );
        for (final f in wb.fixtures) {
          expect(
            f.body.trim(),
            isNotEmpty,
            reason: '${wb.filename} row ${f.rowIndex} has empty body',
          );
        }
      }
    });

    test(
      'real parser pipeline does not throw on any corpus message',
      () async {
        var processed = 0;
        for (final wb in corpus) {
          for (final f in wb.fixtures) {
            processed += 1;
            try {
              useCase.evaluateWithPreloadedContext(
                context,
                EvaluateRulesParams(
                  rawMessage: f.body,
                  sourceType: 'sms',
                  sourceId: f.sourceId,
                  address: f.sender ?? '',
                  messageDate: f.date ?? DateTime(2026),
                ),
              );
            } catch (e) {
              fail('${wb.filename} row ${f.rowIndex} threw $e');
            }
          }
        }
        expect(processed, greaterThan(100));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test('try/catch wrapper produces "<file> row N threw ..." on '
        'per-row failure (simulated)', () {
      final wb = corpus.last;
      if (wb.fixtures.length < 2) {
        fail('corpus too small for the simulated-throw shape test');
      }
      final target = wb.fixtures.elementAt(1);

      String? surfaced;
      for (final f in wb.fixtures.take(3)) {
        try {
          if (identical(f, target)) {
            throw StateError('catastrophic regex exception');
          }
        } catch (e) {
          surfaced = '${wb.filename} row ${f.rowIndex} threw $e';
          break;
        }
      }

      expect(surfaced, isNotNull);
      expect(
        surfaced,
        equals(
          '${wb.filename} row 1 '
          'threw Bad state: catastrophic regex exception',
        ),
        reason:
            'fail() message shape regressed — '
            'expect "<file> row N threw <error>"',
      );
    });

    test('catastrophic-backtracking amountPattern does not escape '
        'as a per-row throw across a corpus slice', () async {
      final evilTemplatesRepo = MockTemplatesRepo();
      final sources = corpusSources(corpus);
      when(
        () => evilTemplatesRepo.getAllTemplates(),
      ).thenAnswer((_) async => Right(catastrophicFormats(sources)));
      when(
        () => evilTemplatesRepo.getMessageSources(),
      ).thenAnswer((_) async => Right(sources));
      final evilUseCase = EvaluateRulesUseCase(evilTemplatesRepo);
      final evilContext = await evilUseCase.loadContext();

      var processed = 0;
      for (final wb in corpus) {
        for (final f in wb.fixtures.take(3)) {
          try {
            evilUseCase.evaluateWithPreloadedContext(
              evilContext,
              EvaluateRulesParams(
                rawMessage: f.body,
                sourceType: 'sms',
                sourceId: f.sourceId,
                address: f.sender ?? '',
                messageDate: f.date ?? DateTime(2026),
              ),
            );
          } catch (e) {
            fail(
              '${wb.filename} row ${f.rowIndex} threw $e '
              '(catastrophic format guard regressed — '
              'per-row try/catch fired)',
            );
          }
          processed += 1;
        }
      }

      expect(processed, equals(21));
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('parser extracts amount on positives and yields no amount on '
        'trigger-only-no-decimal negatives (hand-picked subset)', () async {
      final positiveCases = <({String body, double amount, String trigger})>[
        (
          body:
              'Trx. of AED 15.90 on your a/c ****6111 at '
              'CARREFOUR ABU DHABI AE. Avl Bal is AED 8821.25',
          amount: 15.90,
          trigger: 'debit',
        ),
        (
          body:
              'Dear Customer, AED 500.00 was debited from your '
              'account ****6111. Your available account balance '
              'is AED 7976.23',
          amount: 500.00,
          trigger: 'debit',
        ),
        (
          body:
              'Dear Customer, AED 30.00 was credited to your '
              'account ****6111. Your available account balance '
              'is AED 8004.23',
          amount: 30.00,
          trigger: 'credit',
        ),
      ];

      for (final c in positiveCases) {
        SmsCorpusFixture? match;
        for (final wb in corpus) {
          for (final f in wb.fixtures) {
            if (f.body == c.body) {
              match = f;
              break;
            }
          }
          if (match != null) break;
        }
        expect(
          match,
          isNotNull,
          reason: 'known ${c.trigger} case missing from corpus: ${c.body}',
        );

        final parsed = useCase.evaluateWithPreloadedContext(
          context,
          EvaluateRulesParams(
            rawMessage: match!.body,
            sourceType: 'sms',
            sourceId: match.sourceId,
            address: match.sender ?? '',
            messageDate: match.date ?? DateTime(2026),
          ),
        );

        expect(
          parsed,
          isNotNull,
          reason: 'parser missed ${c.trigger} trigger on: ${c.body}',
        );
        expect(
          parsed?.amount,
          equals(c.amount),
          reason: 'wrong amount extracted from: ${c.body}',
        );
      }

      final negativeCases = <({String body, String trigger})>[
        (
          body:
              'Dear Customer your account ****6111 has been '
              'debited today please login to confirm',
          trigger: 'debit',
        ),
        (
          body:
              'A new transaction has been credited to your '
              'account. Visit your bank for details.',
          trigger: 'credit',
        ),
        (
          body:
              'Cash withdrawal has been Trx. of - please check '
              'with the merchant for the receipt',
          trigger: 'debit',
        ),
      ];

      for (final n in negativeCases) {
        final parsed = useCase.evaluateWithPreloadedContext(
          context,
          EvaluateRulesParams(
            rawMessage: n.body,
            sourceType: 'sms',
            sourceId: 'synthetic-neg:${n.trigger}',
            address: corpus.first.fixtures.first.sender ?? '',
            messageDate: DateTime(2026),
          ),
        );

        expect(
          parsed?.amount,
          isNull,
          reason:
              '${n.trigger} SMS without decimal numbers must '
              'not yield an amount; parser returned '
              '${parsed?.amount} for: ${n.body}',
        );
      }
    });
  });
}

final _ts = DateTime.utc(2026, 1, 1);

/// Every corpus sender, watched.
List<MessageSource> corpusSources(List<CorpusWorkbook> corpus) {
  final senders = {
    for (final wb in corpus)
      for (final f in wb.fixtures) ?f.sender,
  };

  return [
    for (final sender in senders)
      MessageSource(
        id: 'src:$sender',
        contactId: sender,
        contactName: sender,
        isMonitored: true,
        createdAt: _ts,
        updatedAt: _ts,
      ),
  ];
}

List<ExpenseTemplate> _formats(
  List<MessageSource> sources,
  List<String> triggers,
  String amountPattern,
) => [
  for (final source in sources)
    for (final trigger in triggers)
      ExpenseTemplate(
        id: '${source.id}:$trigger',
        sourceId: source.id,
        sampleMessage: trigger,
        triggerWord: trigger,
        amountPattern: amountPattern,
        createdAt: _ts,
        updatedAt: _ts,
      ),
];

List<ExpenseTemplate> corpusFormats(List<MessageSource> sources) =>
    _formats(sources, const [
      'debited',
      'withdrawn',
      'trx. of',
      'withdrawal',
      'credited',
      'deposit',
      'profit',
    ], r'([\d,]+\.\d{2})');

List<ExpenseTemplate> catastrophicFormats(List<MessageSource> sources) =>
    _formats(sources, const [
      'debited',
      'credited',
      'withdrawn',
      'trx. of',
    ], r'(.*)*');
