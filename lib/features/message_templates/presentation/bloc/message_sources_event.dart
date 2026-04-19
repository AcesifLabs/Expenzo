import 'package:equatable/equatable.dart';
import '../../domain/entities/message_source.dart';

abstract class MessageSourcesEvent extends Equatable {
  const MessageSourcesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessageSources extends MessageSourcesEvent {}

class ToggleSourceMonitoring extends MessageSourcesEvent {
  final MessageSource source;
  final bool isMonitored;

  const ToggleSourceMonitoring({
    required this.source,
    required this.isMonitored,
  });

  @override
  List<Object?> get props => [source, isMonitored];
}

class UpdateSourceAutoCreate extends MessageSourcesEvent {
  final MessageSource source;
  final AutoCreateOption option;

  const UpdateSourceAutoCreate({required this.source, required this.option});

  @override
  List<Object?> get props => [source, option];
}
