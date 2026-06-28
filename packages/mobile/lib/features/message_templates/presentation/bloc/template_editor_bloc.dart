import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<LoadTemplate>(_onLoadTemplate);
    on<SaveTemplateEvent>(_onSaveTemplate);
    on<DeleteTemplateEvent>(_onDeleteTemplate);
  }

  Future<void> _onLoadTemplate(
    LoadTemplate event,
    Emitter<TemplateEditorState> emit,
  ) async {}

  Future<void> _onSaveTemplate(
    SaveTemplateEvent event,
    Emitter<TemplateEditorState> emit,
  ) async {
    emit(TemplateEditorSaving());

    final sourceResult = await repository.saveMessageSource(event.source);

    if (sourceResult.isLeft()) {
      sourceResult.fold(
        (failure) => emit(TemplateEditorError(failure.message)),
        (_) {},
      );
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
