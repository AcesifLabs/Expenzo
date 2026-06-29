import 'package:equatable/equatable.dart';
import '../../domain/entities/message_source.dart';

sealed class MessageSourcesState extends Equatable {
  @override
  List<Object?> get props => [];

  const MessageSourcesState();
}

class MessageSourcesInitial extends MessageSourcesState {
  const MessageSourcesInitial();
}

class MessageSourcesLoading extends MessageSourcesState {
  const MessageSourcesLoading();
}

class MessageSourcesLoaded extends MessageSourcesState {
  final List<MessageSource> sources;

  @override
  List<Object?> get props => [sources];

  const MessageSourcesLoaded({required this.sources});
}

class MessageSourcesError extends MessageSourcesState {
  final String message;

  @override
  List<Object?> get props => [message];

  const MessageSourcesError({required this.message});
}
