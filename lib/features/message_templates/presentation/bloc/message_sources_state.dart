import 'package:equatable/equatable.dart';
import '../../domain/entities/message_source.dart';

abstract class MessageSourcesState extends Equatable {
  const MessageSourcesState();

  @override
  List<Object?> get props => [];
}

class MessageSourcesInitial extends MessageSourcesState {}

class MessageSourcesLoading extends MessageSourcesState {}

class MessageSourcesLoaded extends MessageSourcesState {
  final List<MessageSource> sources;

  const MessageSourcesLoaded({required this.sources});

  @override
  List<Object?> get props => [sources];
}

class MessageSourcesError extends MessageSourcesState {
  final String message;

  const MessageSourcesError({required this.message});

  @override
  List<Object?> get props => [message];
}
