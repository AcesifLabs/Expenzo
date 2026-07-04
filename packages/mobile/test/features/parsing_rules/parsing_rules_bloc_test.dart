import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/get_rules.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/update_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/usecases/delete_rule.dart';
import 'package:expense_tracker/features/parsing_rules/domain/repositories/parsing_rules_repository.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_bloc.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_event.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_state.dart';

class MockGetRules extends Mock implements GetRules {}

class _GetRulesParamsFake extends Fake implements GetRulesParams {}

class MockUpdateRule extends Mock implements UpdateRule {}

class MockDeleteRule extends Mock implements DeleteRule {}

class MockParsingRulesRepository extends Mock
    implements ParsingRulesRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(_GetRulesParamsFake());
  });

  late MockGetRules mockGetRules;
  late MockUpdateRule mockUpdateRule;
  late MockDeleteRule mockDeleteRule;
  late MockParsingRulesRepository mockRepository;
  late ParsingRulesBloc bloc;

  final testRule = ParsingRule(
    id: 'rule-1',
    name: 'Test Rule',
    triggerWords: ['test'],
    amountPattern: r'\d+\.\d{2}',
    categoryId: 'cat-1',
    sourceType: SourceType.sms,
    isEnabled: true,
    priority: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockGetRules = MockGetRules();
    mockUpdateRule = MockUpdateRule();
    mockDeleteRule = MockDeleteRule();
    mockRepository = MockParsingRulesRepository();
    bloc = ParsingRulesBloc(
      getRules: mockGetRules,
      updateRule: mockUpdateRule,
      deleteRuleUseCase: mockDeleteRule,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadRules', () {
    test(
      'emits [ParsingRulesLoading, ParsingRulesLoaded] on success',
      () async {
        when(
          () => mockRepository.watchRules(),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => mockGetRules(any()),
        ).thenAnswer((_) async => Right([testRule]));

        final expected = [
          isA<ParsingRulesLoading>(),
          isA<ParsingRulesLoaded>().having(
            (s) => s.rules.length,
            'rules length',
            1,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(LoadRules());
      },
    );

    test('emits [ParsingRulesLoading, ParsingRulesError] on failure', () async {
      when(
        () => mockRepository.watchRules(),
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockGetRules(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Failed to load')));

      final expected = [
        isA<ParsingRulesLoading>(),
        isA<ParsingRulesError>().having(
          (s) => s.message,
          'message',
          'Failed to load',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(LoadRules());
    });
  });

  group('ToggleRule', () {
    test('does nothing when state is not ParsingRulesLoaded', () async {
      final expectation = expectLater(
        bloc.stream,
        neverEmits(isA<ParsingRulesError>()),
      );
      bloc.add(ToggleRule(ruleId: 'rule-1', isEnabled: false));
      await Future.delayed(Duration.zero);
      await bloc.close();
      await expectation;
    });
  });
}
