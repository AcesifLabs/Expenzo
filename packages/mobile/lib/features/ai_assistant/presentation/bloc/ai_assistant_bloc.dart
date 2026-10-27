import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/ai_assistant/domain/constants/ai_assistant.constants.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/build_financial_context.dart';
import '../../domain/usecases/send_ai_message.dart';
import '../../domain/usecases/validate_ai_prompt.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  final BuildFinancialContext buildFinancialContext;
  final SendMessageStream sendMessageStream;
  final ValidateAiPrompt validateAiPrompt;
  final DateTime Function() nowProvider;

  Timer? _cooldownTimer;

  AiAssistantBloc({
    required this.buildFinancialContext,
    required this.sendMessageStream,
    required this.validateAiPrompt,
    DateTime Function()? nowProvider,
  }) : nowProvider = nowProvider ?? DateTime.now,
       super(const AiAssistantState()) {
    on<LoadContext>(_onLoadContext);
    on<SendMessage>(_onSendMessage);
    on<RetryLastMessage>(_onRetryLastMessage);
    on<StreamTokenReceived>(_onStreamTokenReceived);
    on<StreamCompleted>(_onStreamCompleted);
    on<CooldownExpired>(_onCooldownExpired);
    on<StreamError>(_onStreamError);
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();

    return super.close();
  }

  Future<void> _onLoadContext(
    LoadContext event,
    Emitter<AiAssistantState> emit,
  ) async {
    emit(state.copyWith(isLoadingContext: true));

    final result = await buildFinancialContext();
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingContext: false,
          error: t.aiAssistant.errors.contextFailed,
        ),
      ),
      (context) => emit(
        state.copyWith(financialContext: context, isLoadingContext: false),
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AiAssistantState> emit,
  ) async {
    final now = nowProvider();
    final cooldownUntil = state.cooldownUntil;
    if (cooldownUntil != null && now.isBefore(cooldownUntil)) {
      emit(
        state.copyWith(
          error: AiAssistantConstants.cooldownRefusal,
          failedPrompt: null,
        ),
      );

      return;
    }

    final validation = validateAiPrompt(event.text);
    final userMessage = ChatMessage.user(event.text.trim());

    if (!validation.isAllowed) {
      final refusal = ChatMessage.assistant(
        validation.refusalMessage ?? AiAssistantConstants.outOfScopeRefusal,
      );

      emit(
        state.copyWith(
          messages: [...state.messages, userMessage, refusal],
          isComposing: false,
          error: null,
          failedPrompt: null,
          cooldownUntil: _startCooldown(),
        ),
      );

      return;
    }

    await _requestReply(
      emit,
      history: [...state.messages, userMessage],
      prompt: validation.normalizedPrompt,
    );
  }

  Future<void> _onRetryLastMessage(
    RetryLastMessage event,
    Emitter<AiAssistantState> emit,
  ) async {
    final prompt = state.failedPrompt;
    if (prompt == null || state.isComposing) return;

    final history = List<ChatMessage>.from(state.messages);
    while (history.isNotEmpty && history.last.role == ChatRole.assistant) {
      history.removeLast();
    }

    await _requestReply(emit, history: history, prompt: prompt);
  }

  /// [history] must already end with the user's message.
  Future<void> _requestReply(
    Emitter<AiAssistantState> emit, {
    required List<ChatMessage> history,
    required String prompt,
  }) async {
    var financialContext = state.financialContext;
    if (financialContext.isEmpty) {
      emit(
        state.copyWith(
          messages: history,
          isLoadingContext: true,
          error: null,
          failedPrompt: null,
        ),
      );

      final contextResult = await buildFinancialContext();
      final contextValue = contextResult.fold<String?>((failure) {
        final refusal = ChatMessage.assistant(
          t.aiAssistant.refusals.contextUnavailable,
        );
        emit(
          state.copyWith(
            messages: [...history, refusal],
            isLoadingContext: false,
            isComposing: false,
            error: null,
            cooldownUntil: _startCooldown(),
          ),
        );

        return null;
      }, (context) => context);

      if (contextValue == null) {
        return;
      }

      financialContext = contextValue;
      emit(
        state.copyWith(
          financialContext: financialContext,
          isLoadingContext: false,
        ),
      );
    }

    emit(
      state.copyWith(
        messages: [...history, ChatMessage.assistant('')],
        isComposing: true,
        error: null,
        failedPrompt: null,
        cooldownUntil: _startCooldown(),
      ),
    );

    sendMessageStream(message: prompt, context: financialContext).listen(
      (either) => either.fold(
        (failure) => add(StreamError(failureText(failure), prompt: prompt)),
        (token) => add(StreamTokenReceived(token)),
      ),
      onDone: () => add(const StreamCompleted()),
      onError: (Object error) =>
          add(StreamError(error.toString(), prompt: prompt)),
    );
  }

  void _onStreamTokenReceived(
    StreamTokenReceived event,
    Emitter<AiAssistantState> emit,
  ) {
    final messages = List<ChatMessage>.from(state.messages);
    if (messages.isEmpty) return;

    final last = messages.last;
    if (last.role != ChatRole.assistant) return;

    final updated = ChatMessage(
      role: ChatRole.assistant,
      content: last.content + event.token,
      timestamp: last.timestamp,
    );

    messages
      ..removeLast()
      ..add(updated);

    emit(state.copyWith(messages: messages));
  }

  void _onStreamCompleted(
    StreamCompleted event,
    Emitter<AiAssistantState> emit,
  ) {
    emit(
      state.copyWith(
        messages: _withoutPendingReply(state.messages),
        isComposing: false,
      ),
    );
  }

  void _onCooldownExpired(
    CooldownExpired event,
    Emitter<AiAssistantState> emit,
  ) {
    emit(state.copyWith(cooldownUntil: null, error: null));
  }

  void _onStreamError(StreamError event, Emitter<AiAssistantState> emit) {
    emit(
      state.copyWith(
        messages: _withoutPendingReply(state.messages),
        isComposing: false,
        isLoadingContext: false,
        error: event.message,
        failedPrompt: event.prompt,
      ),
    );
  }

  List<ChatMessage> _withoutPendingReply(List<ChatMessage> messages) {
    if (messages.isEmpty || !messages.last.isPendingReply) return messages;

    return messages.sublist(0, messages.length - 1);
  }

  DateTime _startCooldown() {
    _cooldownTimer?.cancel();

    final cooldownUntil = nowProvider().add(
      AiAssistantConstants.cooldownDuration,
    );
    _cooldownTimer = Timer(
      AiAssistantConstants.cooldownDuration,
      () => add(const CooldownExpired()),
    );

    return cooldownUntil;
  }
}
