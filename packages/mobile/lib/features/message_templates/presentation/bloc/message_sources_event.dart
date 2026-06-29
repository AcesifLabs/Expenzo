import 'package:equatable/equatable.dart';
import '../../domain/entities/message_source.dart';

abstract class MessageSourcesEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const MessageSourcesEvent();
}

class LoadMessageSources extends MessageSourcesEvent {}

class ToggleSourceMonitoring extends MessageSourcesEvent {
  final MessageSource source;
  final bool isMonitored;

  @override
  List<Object?> get props => [source, isMonitored];

  const ToggleSourceMonitoring({
    required this.source,
    required this.isMonitored,
  });
}

class UpdateSourceAutoCreate extends MessageSourcesEvent {
  final MessageSource source;
  final AutoCreateOption option;

  @override
  List<Object?> get props => [source, option];

  const UpdateSourceAutoCreate({required this.source, required this.option});
}
