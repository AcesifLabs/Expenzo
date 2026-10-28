import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

const _cooldownSentinel = Object();
const _failedPromptSentinel = Object();

class AiAssistantState extends Equatable {
  final List<ChatMessage> messages;
  final String financialContext;
  final bool isLoadingContext;
  final bool isComposing;
  final DateTime? cooldownUntil;
  final String? error;

  /// Prompt whose reply failed; set until a retry or a new message.
  final String? failedPrompt;

  @override
  List<Object?> get props => [
    messages,
    financialContext,
    isLoadingContext,
    isComposing,
    cooldownUntil,
    error,
    failedPrompt,
  ];

  const AiAssistantState({
    this.messages = const [],
    this.financialContext = '',
    this.isLoadingContext = false,
    this.isComposing = false,
    this.cooldownUntil,
    this.error,
    this.failedPrompt,
  });

  AiAssistantState copyWith({
    List<ChatMessage>? messages,
    String? financialContext,
    bool? isLoadingContext,
    bool? isComposing,
    Object? cooldownUntil = _cooldownSentinel,
    String? error,
    Object? failedPrompt = _failedPromptSentinel,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      financialContext: financialContext ?? this.financialContext,
      isLoadingContext: isLoadingContext ?? this.isLoadingContext,
      isComposing: isComposing ?? this.isComposing,
      cooldownUntil: identical(cooldownUntil, _cooldownSentinel)
          ? this.cooldownUntil
          : cooldownUntil as DateTime?,
      error: error,
      failedPrompt: identical(failedPrompt, _failedPromptSentinel)
          ? this.failedPrompt
          : failedPrompt as String?,
    );
  }
}
