import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

const _cooldownSentinel = Object();

class AiAssistantState extends Equatable {
  final List<ChatMessage> messages;
  final String financialContext;
  final bool isLoadingContext;
  final bool isComposing;
  final DateTime? cooldownUntil;
  final String? error;

  @override
  List<Object?> get props => [
    messages,
    financialContext,
    isLoadingContext,
    isComposing,
    cooldownUntil,
    error,
  ];

  const AiAssistantState({
    this.messages = const [],
    this.financialContext = '',
    this.isLoadingContext = false,
    this.isComposing = false,
    this.cooldownUntil,
    this.error,
  });

  AiAssistantState copyWith({
    List<ChatMessage>? messages,
    String? financialContext,
    bool? isLoadingContext,
    bool? isComposing,
    Object? cooldownUntil = _cooldownSentinel,
    String? error,
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
    );
  }
}
