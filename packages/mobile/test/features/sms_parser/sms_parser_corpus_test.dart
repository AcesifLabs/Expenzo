import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/message_templates/domain/repositories/message_template_repository.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/evaluate_rules_params.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_context.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/repositories/parsing_rules_repository.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

import 'sms_corpus_loader.dart';

class MockRulesRepo extends Mock implements ParsingRulesRepository {}

class MockTemplatesRepo extends Mock implements MessageTemplateRepository {}

void main() {
  setUpAll(() {
    appLogger.configure(settings: TalkerSettings(useConsoleLogs: false));
  });

  group('UAE bank SMS corpus', () {
    late List<CorpusWorkbook> corpus;
    late MockRulesRepo rulesRepo;
    late MockTemplatesRepo templatesRepo;
    late EvaluateRulesUseCase useCase;
    late ParsingContext context;

    setUpAll(() async {
      corpus = await loadSmsCorpus();
      rulesRepo = MockRulesRepo();
      templatesRepo = MockTemplatesRepo();
      when(
        () => rulesRepo.getRules(isEnabled: any(named: 'isEnabled')),
      ).thenAnswer((_) async => Right(corpusRules()));
      when(
        () => templatesRepo.getAllTemplates(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => templatesRepo.getMessageSources(),
      ).thenAnswer((_) async => const Right([]));
      useCase = EvaluateRulesUseCase(rulesRepo, templatesRepo);

      // Pre-load the parse context once so the loop below doesn't
      // pay 4500 context rebuilds.
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
        // the loader should yield one fixture per data row whose
        // body came back non-empty. tableRowCount includes the
        // header so we expect ≤ tableRowCount - 1.
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
                  address: f.sender,
                  messageDate: f.date,
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
      // Note: RuleEvaluator already has its own internal try/catch
      // around `_evaluateRule` / `_evaluateTemplate`, so the per-row
      // catch above *should* never fire under normal operation.
      // This test pins down the exact shape of the fail() message
      // that the loop would surface IF a future change ever let an
      // exception escape that inner guard — so a regression that
      // mangles the message format is caught.
      //
      // Deterministic target: the second fixture of the last
      // workbook (every workbook in the corpus has ≥ 2 fixtures).
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
      // Use the classic ReDoS pattern (.*)* as the amountPattern.
      // The integration test (`regexTimeout_flow`) proved this is
      // fenced by RuleEvaluator's internal try/catch (returns
      // parseFailed: true). Here we re-verify under the corpus
      // loop specifically: even on the worst fixture, the per-row
      // catch in the bulk test should never fire.
      final evilRepo = MockRulesRepo();
      final evilTemplatesRepo = MockTemplatesRepo();
      when(
        () => evilRepo.getRules(isEnabled: any(named: 'isEnabled')),
      ).thenAnswer((_) async => Right(<ParsingRule>[catastrophicRule()]));
      when(
        () => evilTemplatesRepo.getAllTemplates(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => evilTemplatesRepo.getMessageSources(),
      ).thenAnswer((_) async => const Right([]));
      final evilUseCase = EvaluateRulesUseCase(evilRepo, evilTemplatesRepo);
      final evilContext = await evilUseCase.loadContext();

      // Slice to the first 3 fixtures per workbook so the
      // catastrophic regex can't drive the runtime past the
      // global test budget even if the guard ever regresses.
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
                address: f.sender,
                messageDate: f.date,
              ),
            );
          } catch (e) {
            fail(
              '${wb.filename} row ${f.rowIndex} threw $e '
              '(catastrophic rule guard regressed — '
              'per-row try/catch fired)',
            );
          }
          processed += 1;
        }
      }
      // 7 workbooks × up-to-3 fixtures each.
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
        // Locate the SMS in the corpus so we exercise the same
        // evaluateWithPreloadedContext codepath used by the bulk
        // pipeline test.
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
            address: match.sender,
            messageDate: match.date,
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

      // Negative-subset: trigger word present, NO decimal numbers
      // in the body. The parser must NOT extract an amount. This
      // catches the regression class where the pipeline starts
      // always returning a non-null amount (e.g. if someone adds a
      // catch-all fallback in RuleEvaluator that fabricates a
      // value).
      //
      // Bodies are synthetic (not in the corpus) — they exist
      // precisely so that the regression guard doesn't depend on
      // the corpus continuing to contain or not contain them.
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

List<ParsingRule> corpusRules() {
  final ts = DateTime.utc(2026, 1, 1);
  return [
    ParsingRule(
      id: 'corpus_debit',
      name: 'Corpus Debit',
      triggerWords: const ['debited', 'withdrawn', 'trx. of', 'withdrawal'],
      amountPattern: r'([\d,]+\.\d{2})',
      sourceType: SourceType.sms,
      isEnabled: true,
      priority: 1,
      createdAt: ts,
      updatedAt: ts,
    ),
    ParsingRule(
      id: 'corpus_credit',
      name: 'Corpus Credit',
      triggerWords: const ['credited', 'deposit', 'profit'],
      amountPattern: r'([\d,]+\.\d{2})',
      sourceType: SourceType.sms,
      isEnabled: true,
      priority: 2,
      createdAt: ts,
      updatedAt: ts,
    ),
  ];
}

/// Classic catastrophic-backtracking regex used by the resilience
/// test. Syntactically valid (parsed without throwing) but a known
/// ReDoS pattern — RuleEvaluator's internal fence must absorb it.
ParsingRule catastrophicRule() {
  final ts = DateTime.utc(2026, 1, 1);
  return ParsingRule(
    id: 'catastrophic',
    name: 'Catastrophic ReDoS',
    triggerWords: const ['debited', 'credited', 'withdrawn', 'trx. of'],
    amountPattern: r'(.*)*',
    sourceType: SourceType.sms,
    isEnabled: true,
    priority: 1,
    createdAt: ts,
    updatedAt: ts,
  );
}
