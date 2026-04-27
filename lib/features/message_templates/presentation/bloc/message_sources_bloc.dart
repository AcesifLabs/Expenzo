import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_message_sources.dart';
import '../../domain/usecases/save_message_source.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'message_sources_event.dart';
import 'message_sources_state.dart';

class MessageSourcesBloc
    extends Bloc<MessageSourcesEvent, MessageSourcesState> {
  final GetMessageSources getMessageSources;
  final SaveMessageSource saveMessageSource;

  MessageSourcesBloc({
    required this.getMessageSources,
    required this.saveMessageSource,
  }) : super(MessageSourcesInitial()) {
    on<LoadMessageSources>(_onLoadMessageSources);
    on<ToggleSourceMonitoring>(_onToggleSourceMonitoring);
    on<UpdateSourceAutoCreate>(_onUpdateSourceAutoCreate);
  }

  Future<void> _onLoadMessageSources(
    LoadMessageSources event,
    Emitter<MessageSourcesState> emit,
  ) async {
    emit(MessageSourcesLoading());
    final result = await getMessageSources(NoParams());
    result.fold(
      (failure) => emit(MessageSourcesError(message: failure.message)),
      (sources) => emit(MessageSourcesLoaded(sources: sources)),
    );
  }

  Future<void> _onToggleSourceMonitoring(
    ToggleSourceMonitoring event,
    Emitter<MessageSourcesState> emit,
  ) async {
    if (state is MessageSourcesLoaded) {
      final updatedSource = event.source.copyWith(
        isMonitored: event.isMonitored,
        updatedAt: DateTime.now(),
      );

      final result = await saveMessageSource(updatedSource);

      result.fold(
        (failure) => emit(MessageSourcesError(message: failure.message)),
        (_) => add(LoadMessageSources()),
      );
    }
  }

  Future<void> _onUpdateSourceAutoCreate(
    UpdateSourceAutoCreate event,
    Emitter<MessageSourcesState> emit,
  ) async {
    if (state is MessageSourcesLoaded) {
      final updatedSource = event.source.copyWith(
        autoCreateOption: event.option,
        updatedAt: DateTime.now(),
      );

      final result = await saveMessageSource(updatedSource);

      result.fold(
        (failure) => emit(MessageSourcesError(message: failure.message)),
        (_) => add(LoadMessageSources()),
      );
    }
  }
}
