import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import '../../domain/usecases/save_template.dart';
import '../../domain/repositories/message_template_repository.dart';
import 'template_editor_event.dart';
import 'template_editor_state.dart';

class TemplateEditorBloc
    extends Bloc<TemplateEditorEvent, TemplateEditorState> {
  final SaveTemplate saveTemplateUseCase;
  final MessageTemplateRepository repository;

  TemplateEditorBloc({
    required this.saveTemplateUseCase,
    required this.repository,
  }) : super(TemplateEditorInitial()) {
    on<SaveTemplateEvent>(_onSaveTemplate, transformer: concurrent());
    on<DeleteTemplateEvent>(_onDeleteTemplate, transformer: concurrent());
  }

  Future<void> _onSaveTemplate(
    SaveTemplateEvent event,
    Emitter<TemplateEditorState> emit,
  ) async {
    emit(TemplateEditorSaving());

    final sourceResult = await repository.saveMessageSource(event.source);

    final sourceError = sourceResult.fold((failure) => failure, (_) => null);
    if (sourceError != null) {
      emit(TemplateEditorError(sourceError.message));

      return;
    }

    final result = await saveTemplateUseCase(event.template);
    result.fold(
      (failure) => emit(TemplateEditorError(failure.message)),
      (_) => emit(TemplateEditorSaved()),
    );
  }

  Future<void> _onDeleteTemplate(
    DeleteTemplateEvent event,
    Emitter<TemplateEditorState> emit,
  ) async {
    emit(TemplateEditorSaving());
    final result = await repository.deleteTemplate(event.templateId);
    result.fold(
      (failure) => emit(TemplateEditorError(failure.message)),
      (_) => emit(TemplateEditorDeleted()),
    );
  }
}
