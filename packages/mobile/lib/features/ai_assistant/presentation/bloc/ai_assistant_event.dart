import 'package:equatable/equatable.dart';

abstract class AiAssistantEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const AiAssistantEvent();
}

class LoadContext extends AiAssistantEvent {
  const LoadContext();
}

class SendMessage extends AiAssistantEvent {
  final String text;

  @override
  List<Object?> get props => [text];

  const SendMessage(this.text);
}

class StreamTokenReceived extends AiAssistantEvent {
  final String token;

  @override
  List<Object?> get props => [token];

  const StreamTokenReceived(this.token);
}

class StreamCompleted extends AiAssistantEvent {
  const StreamCompleted();
}

class CooldownExpired extends AiAssistantEvent {
  const CooldownExpired();
}

class StreamError extends AiAssistantEvent {
  final String message;

  @override
  List<Object?> get props => [message];

  const StreamError(this.message);
}
