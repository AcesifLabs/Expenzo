import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:expense_tracker/features/ai_assistant/domain/entities/prompt_validation_result.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/build_financial_context.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/send_ai_message.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/validate_ai_prompt.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/bloc/ai_assistant_event.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/bloc/ai_assistant_state.dart';

class MockBuildFinancialContext extends Mock implements BuildFinancialContext {}

class MockSendMessageStream extends Mock implements SendMessageStream {}

class MockValidateAiPrompt extends Mock implements ValidateAiPrompt {}

class _Harness {
  final AiAssistantBloc bloc;
  final MockBuildFinancialContext buildContext;
  final MockSendMessageStream sendMessage;
  final MockValidateAiPrompt validatePrompt;

  const _Harness({
    required this.bloc,
    required this.buildContext,
    required this.sendMessage,
    required this.validatePrompt,
  });
}

void main() {
  _Harness? harnessValue;

  _Harness harness() {
    final local = harnessValue;
    if (local == null) {
      throw StateError('Harness not initialized');
    }

    return local;
  }

  setUp(() {
    final buildContext = MockBuildFinancialContext();
    final sendMessage = MockSendMessageStream();
    final validatePrompt = MockValidateAiPrompt();
    final bloc = AiAssistantBloc(
      buildFinancialContext: buildContext,
      sendMessageStream: sendMessage,
      validateAiPrompt: validatePrompt,
    );

    harnessValue = _Harness(
      bloc: bloc,
      buildContext: buildContext,
      sendMessage: sendMessage,
      validatePrompt: validatePrompt,
    );
  });

  tearDown(() => harness().bloc.close());

  group('AiAssistantBloc', () {
    test('initial state is correct', () {
      expect(harness().bloc.state.messages, isEmpty);
      expect(harness().bloc.state.financialContext, isEmpty);
      expect(harness().bloc.state.isLoadingContext, isFalse);
      expect(harness().bloc.state.isComposing, isFalse);
      expect(harness().bloc.state.error, isNull);
    });

    test('LoadContext sets context on success', () async {
      when(
        () => harness().buildContext(),
      ).thenAnswer((_) async => const Right('Financial context data'));

      harness().bloc.add(const LoadContext());

      await expectLater(
        harness().bloc.stream,
        emitsInOrder([
          predicate<AiAssistantState>((s) => s.isLoadingContext),
          predicate<AiAssistantState>(
            (s) =>
                s.financialContext == 'Financial context data' &&
                !s.isLoadingContext,
          ),
        ]),
      );
    });

    test('LoadContext sets error on failure', () async {
      when(
        () => harness().buildContext(),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'test error')));

      harness().bloc.add(const LoadContext());

      await expectLater(
        harness().bloc.stream,
        emitsInOrder([
          predicate<AiAssistantState>((s) => s.isLoadingContext),
          predicate<AiAssistantState>(
            (s) => s.error != null && !s.isLoadingContext,
          ),
        ]),
      );
    });

    test('copyWith creates new state with updated values', () {
      const state = AiAssistantState();
      final updated = state.copyWith(
        financialContext: 'test',
        isLoadingContext: true,
      );

      expect(updated.financialContext, 'test');
      expect(updated.isLoadingContext, isTrue);
      expect(updated.messages, isEmpty);
    });

    test('ChatMessage.user creates user message', () {
      final msg = ChatMessage.user('Hello');

      expect(msg.role, ChatRole.user);
      expect(msg.content, 'Hello');
    });

    test('ChatMessage.assistant creates assistant message', () {
      final msg = ChatMessage.assistant('Response');

      expect(msg.role, ChatRole.assistant);
      expect(msg.content, 'Response');
    });

    test('SendMessage refuses out-of-scope prompt locally', () async {
      when(() => harness().validatePrompt(any())).thenReturn(
        const PromptValidationResult.deny(refusalMessage: 'Refused'),
      );

      harness().bloc.add(const SendMessage('Tell me a joke'));

      await expectLater(
        harness().bloc.stream,
        emits(
          predicate<AiAssistantState>(
            (s) =>
                s.messages.length == 2 &&
                s.messages.first.role == ChatRole.user &&
                s.messages.last.role == ChatRole.assistant &&
                s.messages.last.content == 'Refused' &&
                !s.isComposing,
          ),
        ),
      );

      verifyNever(
        () => harness().sendMessage(
          message: any(named: 'message'),
          context: any(named: 'context'),
        ),
      );
    });

    group('when the reply stream', () {
      Future<List<AiAssistantState>> sendWith(
        Stream<Either<Failure, String>> stream,
      ) async {
        when(
          () => harness().validatePrompt(any()),
        ).thenReturn(const PromptValidationResult.allow('How is my budget?'));
        when(
          () => harness().buildContext(),
        ).thenAnswer((_) async => const Right('finance context'));
        when(
          () => harness().sendMessage(
            message: any(named: 'message'),
            context: any(named: 'context'),
          ),
        ).thenAnswer((_) => stream);

        final states = <AiAssistantState>[];
        final subscription = harness().bloc.stream.listen(states.add);
        harness().bloc.add(const SendMessage('How is my budget?'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await subscription.cancel();

        return states;
      }

      test('fails, it drops the empty reply and reports the error', () async {
        final states = await sendWith(
          Stream.value(const Left(ServerFailure(message: 'No response'))),
        );

        expect(states.any((s) => s.error != null), isTrue);
        expect(states.last.messages, hasLength(1));
        expect(states.last.messages.single.role, ChatRole.user);
        expect(states.last.isComposing, isFalse);
      });

      test('ends without tokens, it drops the empty reply', () async {
        final states = await sendWith(const Stream.empty());

        expect(states.last.messages, hasLength(1));
        expect(states.last.messages.single.role, ChatRole.user);
        expect(states.last.isComposing, isFalse);
      });

      test('fails mid-reply, it keeps the partial text', () async {
        final states = await sendWith(
          Stream.fromIterable(const [
            Right('Partial'),
            Left(ServerFailure(message: 'Dropped')),
          ]),
        );

        expect(states.any((s) => s.error != null), isTrue);
        expect(states.last.messages, hasLength(2));
        expect(states.last.messages.last.content, 'Partial');
      });
    });

    group('RetryLastMessage', () {
      test(
        're-sends the failed prompt without a duplicate user message',
        () async {
          final replies = [
            Stream<Either<Failure, String>>.value(
              const Left(ServerFailure(message: 'No response')),
            ),
            Stream<Either<Failure, String>>.value(const Right('All good')),
          ];
          when(
            () => harness().validatePrompt(any()),
          ).thenReturn(const PromptValidationResult.allow('How is my budget?'));
          when(
            () => harness().buildContext(),
          ).thenAnswer((_) async => const Right('finance context'));
          when(
            () => harness().sendMessage(
              message: any(named: 'message'),
              context: any(named: 'context'),
            ),
          ).thenAnswer((_) => replies.removeAt(0));

          harness().bloc.add(const SendMessage('How is my budget?'));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(harness().bloc.state.failedPrompt, 'How is my budget?');

          harness().bloc.add(const RetryLastMessage());
          await Future<void>.delayed(const Duration(milliseconds: 10));

          final state = harness().bloc.state;
          expect(state.messages.map((m) => m.role), [
            ChatRole.user,
            ChatRole.assistant,
          ]);
          expect(state.messages.last.content, 'All good');
          expect(state.failedPrompt, isNull);
          verify(
            () => harness().sendMessage(
              message: 'How is my budget?',
              context: 'finance context',
            ),
          ).called(2);
        },
      );

      test('drops a partial reply before retrying', () async {
        final replies = [
          Stream<Either<Failure, String>>.fromIterable(const [
            Right('Half'),
            Left(ServerFailure(message: 'Dropped')),
          ]),
          Stream<Either<Failure, String>>.value(const Right('Whole')),
        ];
        when(
          () => harness().validatePrompt(any()),
        ).thenReturn(const PromptValidationResult.allow('How is my budget?'));
        when(
          () => harness().buildContext(),
        ).thenAnswer((_) async => const Right('finance context'));
        when(
          () => harness().sendMessage(
            message: any(named: 'message'),
            context: any(named: 'context'),
          ),
        ).thenAnswer((_) => replies.removeAt(0));

        harness().bloc.add(const SendMessage('How is my budget?'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        harness().bloc.add(const RetryLastMessage());
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final state = harness().bloc.state;
        expect(state.messages, hasLength(2));
        expect(state.messages.last.content, 'Whole');
      });

      test('does nothing when no reply has failed', () async {
        harness().bloc.add(const RetryLastMessage());
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(harness().bloc.state.messages, isEmpty);
        verifyNever(
          () => harness().sendMessage(
            message: any(named: 'message'),
            context: any(named: 'context'),
          ),
        );
      });
    });

    test('SendMessage rate limits rapid repeated prompts', () async {
      var currentTime = DateTime(2026, 1, 1, 12, 0, 0);
      final buildContext = MockBuildFinancialContext();
      final sendMessage = MockSendMessageStream();
      final validatePrompt = MockValidateAiPrompt();
      final bloc = AiAssistantBloc(
        buildFinancialContext: buildContext,
        sendMessageStream: sendMessage,
        validateAiPrompt: validatePrompt,
        nowProvider: () => currentTime,
      );

      when(() => validatePrompt(any())).thenReturn(
        const PromptValidationResult.allow('How much did I spend on food?'),
      );
      when(
        () => buildContext(),
      ).thenAnswer((_) async => const Right('finance context'));
      when(
        () => sendMessage(
          message: any(named: 'message'),
          context: any(named: 'context'),
        ),
      ).thenAnswer((_) => Stream.value(const Right('ok')));

      bloc.add(const SendMessage('How much did I spend on food?'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      currentTime = currentTime.add(const Duration(seconds: 1));
      bloc.add(const SendMessage('How much did I spend on food?'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.error, isNotNull);

      await bloc.close();
    });
  });
}
