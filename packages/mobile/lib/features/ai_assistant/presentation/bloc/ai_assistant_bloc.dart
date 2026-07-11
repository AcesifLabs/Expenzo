import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/ai_assistant/domain/constants/ai_assistant.constants.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/build_financial_context.dart';
import '../../domain/usecases/send_ai_message.dart';
import '../../domain/usecases/validate_ai_prompt.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

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
          error: 'Could not load financial context: ${failure.message}',
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
      emit(state.copyWith(error: AiAssistantConstants.cooldownRefusal));

      return;
    }

    final validation = validateAiPrompt(event.text);
    final userMessage = ChatMessage.user(event.text.trim());

    if (!validation.isAllowed) {
      final refusal = ChatMessage.assistant(
        validation.refusalMessage ??
            'I can only help with your Expenzo finances.',
      );

      emit(
        state.copyWith(
          messages: [...state.messages, userMessage, refusal],
          isComposing: false,
          error: null,
          cooldownUntil: _startCooldown(),
        ),
      );

      return;
    }

    var financialContext = state.financialContext;
    if (financialContext.isEmpty) {
      emit(state.copyWith(isLoadingContext: true, error: null));

      final contextResult = await buildFinancialContext();
      final contextValue = contextResult.fold<String?>((failure) {
        final refusal = ChatMessage.assistant(
          'I can\'t access your finance context right now. Please try again shortly.',
        );
        emit(
          state.copyWith(
            messages: [...state.messages, userMessage, refusal],
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

    final assistantMessage = ChatMessage.assistant('');

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage, assistantMessage],
        isComposing: true,
        error: null,
        cooldownUntil: _startCooldown(),
      ),
    );

    sendMessageStream(
      message: validation.normalizedPrompt,
      context: financialContext,
    ).listen(
      (either) => either.fold(
        (failure) => add(StreamError(failure.message)),
        (token) => add(StreamTokenReceived(token)),
      ),
      onDone: () => add(const StreamCompleted()),
      onError: (error) => add(StreamError(error.toString())),
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
    emit(state.copyWith(isComposing: false));
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
        isComposing: false,
        isLoadingContext: false,
        error: event.message,
      ),
    );
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
