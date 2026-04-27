import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/repositories/parsing_rules_repository.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/evaluate_rules.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_types.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/get_rules.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/update_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/delete_rule.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_bloc.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_event.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_state.dart';

import 'package:expense_tracker/features/message_templates/domain/repositories/message_template_repository.dart';

class MockParsingRulesRepository extends Mock
    implements ParsingRulesRepository {}

class MockMessageTemplateRepository extends Mock
    implements MessageTemplateRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Parsing Rules Integration Tests', () {
    late MockParsingRulesRepository mockRepository;
    late MockMessageTemplateRepository mockTemplateRepository;
    late EvaluateRulesUseCase evaluateRulesUseCase;
    late GetRules getRulesUseCase;
    late UpdateRule updateRuleUseCase;
    late DeleteRule deleteRuleUseCase;
    late ParsingRulesBloc parsingRulesBloc;

    final testRules = [
      ParsingRule(
        id: 'rule_1',
        name: 'Bank Credit',
        triggerWords: ['credited', 'deposit', 'bank'],
        amountPattern: r'(?:Rs\.?|INR)?\s*([\d,]+\.?\d*)',
        sourceType: SourceType.sms,
        isEnabled: true,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ParsingRule(
        id: 'rule_2',
        name: 'UPI Payment',
        triggerWords: ['UPI', 'upi', 'paytm', 'gpay'],
        amountPattern: r'(?:Rs\.?|INR)?\s*([\d,]+\.?\d*)',
        sourceType: SourceType.sms,
        isEnabled: true,
        priority: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setUp(() {
      mockRepository = MockParsingRulesRepository();
      mockTemplateRepository = MockMessageTemplateRepository();
      evaluateRulesUseCase = EvaluateRulesUseCase(
        mockRepository,
        mockTemplateRepository,
      );
      getRulesUseCase = GetRules(mockRepository);
      updateRuleUseCase = UpdateRule(mockRepository);
      deleteRuleUseCase = DeleteRule(mockRepository);
      parsingRulesBloc = ParsingRulesBloc(
        getRules: getRulesUseCase,
        updateRule: updateRuleUseCase,
        deleteRuleUseCase: deleteRuleUseCase,
        repository: mockRepository,
      );
    });

    tearDown(() {
      parsingRulesBloc.close();
    });

    test('createRule_flow creates rule and verifies in list', () async {
      when(
        () => mockRepository.getRules(isEnabled: any(named: 'isEnabled')),
      ).thenAnswer((_) async => Right([]));
      when(
        () => mockRepository.watchRules(),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.createRule(any()),
      ).thenAnswer((_) async => Right(testRules.first));

      final result = await getRulesUseCase(GetRulesParams());

      expect(result.isRight(), isTrue);
    });

    test('testRegex_flow parses amount correctly from sample SMS', () async {
      when(
        () => mockRepository.getRules(
          sourceType: any(named: 'sourceType'),
          isEnabled: true,
        ),
      ).thenAnswer((_) async => Right(testRules));
      when(
        () => mockTemplateRepository.getAllTemplates(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockTemplateRepository.getMessageSources(),
      ).thenAnswer((_) async => const Right([]));

      const sampleSms = 'Your bank account is credited with Rs. 5000';

      final result = await evaluateRulesUseCase(
        EvaluateRulesParams(
          rawMessage: sampleSms,
          sourceType: 'sms',
          sourceId: 'test_source_1',
        ),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (parsed) {
        expect(parsed, isNotNull);
        expect(parsed!.amount, equals(5000.0));
        expect(parsed.confidenceScore, greaterThan(0.5));
      });
    });

    test('firstMatchWins_flow first rule in priority order wins', () async {
      final highPriorityRules = [
        testRules[1].copyWith(priority: 10),
        testRules[0].copyWith(priority: 5),
      ];

      when(
        () => mockRepository.getRules(
          sourceType: any(named: 'sourceType'),
          isEnabled: true,
        ),
      ).thenAnswer((_) async => Right(highPriorityRules));
      when(
        () => mockTemplateRepository.getAllTemplates(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockTemplateRepository.getMessageSources(),
      ).thenAnswer((_) async => const Right([]));

      const sampleSms = 'UPI payment Rs. 500 received';

      final result = await evaluateRulesUseCase(
        EvaluateRulesParams(
          rawMessage: sampleSms,
          sourceType: 'sms',
          sourceId: 'test_source_2',
        ),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (parsed) {
        expect(parsed, isNotNull);
        expect(parsed!.matchedRuleId, equals(highPriorityRules[0].id));
      });
    });

    test('regexTimeout_flow dangerous regex marked as failed', () async {
      final dangerousRule = ParsingRule(
        id: 'dangerous_rule',
        name: 'Dangerous Rule',
        triggerWords: ['test'],
        amountPattern: r'(.*)*', // Catastrophic backtracking pattern
        sourceType: SourceType.sms,
        isEnabled: true,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        () => mockRepository.getRules(
          sourceType: any(named: 'sourceType'),
          isEnabled: true,
        ),
      ).thenAnswer((_) async => Right([dangerousRule]));
      when(
        () => mockTemplateRepository.getAllTemplates(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockTemplateRepository.getMessageSources(),
      ).thenAnswer((_) async => const Right([]));

      const sampleSms = 'Test message with Rs. 100';

      final result = await evaluateRulesUseCase(
        EvaluateRulesParams(
          rawMessage: sampleSms,
          sourceType: 'sms',
          sourceId: 'test_source_3',
        ),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (parsed) {
        expect(parsed, isNotNull);
      });
    });

    test('multipleRulesMatch_flow only first match is returned', () async {
      when(
        () => mockRepository.getRules(
          sourceType: any(named: 'sourceType'),
          isEnabled: true,
        ),
      ).thenAnswer((_) async => Right(testRules));
      when(
        () => mockTemplateRepository.getAllTemplates(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockTemplateRepository.getMessageSources(),
      ).thenAnswer((_) async => const Right([]));

      const sampleSms = 'Bank UPI transaction credited Rs. 1000';

      final result = await evaluateRulesUseCase(
        EvaluateRulesParams(
          rawMessage: sampleSms,
          sourceType: 'sms',
          sourceId: 'test_source_4',
        ),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (parsed) {
        expect(parsed, isNotNull);
        expect(parsed!.matchedRuleId, isNotNull);
      });
    });

    test('editRule_flow updates rule behavior', () async {
      final updatedRule = testRules.first.copyWith(
        name: 'Updated Bank Credit',
        updatedAt: DateTime.now(),
      );

      when(
        () => mockRepository.getRules(isEnabled: any(named: 'isEnabled')),
      ).thenAnswer((_) async => Right([updatedRule]));
      when(
        () => mockRepository.watchRules(),
      ).thenAnswer((_) => Stream.value([updatedRule]));
      when(
        () => mockRepository.updateRule(any()),
      ).thenAnswer((_) async => Right(updatedRule));

      parsingRulesBloc.add(LoadRules());

      await Future.delayed(const Duration(milliseconds: 100));

      expect(parsingRulesBloc.state, isA<ParsingRulesLoaded>());
    });

    test('deleteRule_flow removes rule from list', () async {
      when(
        () => mockRepository.getRules(isEnabled: any(named: 'isEnabled')),
      ).thenAnswer((_) async => Right([]));
      when(
        () => mockRepository.watchRules(),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.deleteRule(any()),
      ).thenAnswer((_) async => const Right(unit));

      parsingRulesBloc.add(const DeleteRuleRequested(ruleId: 'rule_to_delete'));

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockRepository.deleteRule('rule_to_delete')).called(1);
    });

    test('loadRules_flow emits loading then loaded states', () async {
      when(
        () => mockRepository.getRules(isEnabled: any(named: 'isEnabled')),
      ).thenAnswer((_) async => Right(testRules));
      when(
        () => mockRepository.watchRules(),
      ).thenAnswer((_) => Stream.value(testRules));

      parsingRulesBloc.add(LoadRules());

      await expectLater(
        parsingRulesBloc.stream,
        emitsInOrder([isA<ParsingRulesLoading>(), isA<ParsingRulesLoaded>()]),
      );
    });

    test('toggleRule_flow updates rule enabled status', () async {
      final toggledRule = testRules.first.copyWith(
        isEnabled: false,
        updatedAt: DateTime.now(),
      );

      when(
        () => mockRepository.getRules(isEnabled: any(named: 'isEnabled')),
      ).thenAnswer((_) async => Right(testRules));
      when(
        () => mockRepository.watchRules(),
      ).thenAnswer((_) => Stream.value([toggledRule]));
      when(
        () => mockRepository.updateRule(any()),
      ).thenAnswer((_) async => Right(toggledRule));

      parsingRulesBloc.add(
        ToggleRule(ruleId: testRules.first.id, isEnabled: false),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockRepository.updateRule(any())).called(1);
    });
  });
}
