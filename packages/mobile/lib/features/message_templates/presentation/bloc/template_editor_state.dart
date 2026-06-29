import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_template.dart';

sealed class TemplateEditorState extends Equatable {
  @override
  List<Object?> get props => [];

  const TemplateEditorState();
}

class TemplateEditorInitial extends TemplateEditorState {
  const TemplateEditorInitial();
}

class TemplateEditorLoading extends TemplateEditorState {
  const TemplateEditorLoading();
}

class TemplateEditorLoaded extends TemplateEditorState {
  final ExpenseTemplate? template;

  @override
  List<Object?> get props => [template];

  const TemplateEditorLoaded({this.template});
}

class TemplateEditorSaving extends TemplateEditorState {
  const TemplateEditorSaving();
}

class TemplateEditorSaved extends TemplateEditorState {
  const TemplateEditorSaved();
}

class TemplateEditorDeleted extends TemplateEditorState {
  const TemplateEditorDeleted();
}

class TemplateEditorError extends TemplateEditorState {
  final String message;

  @override
  List<Object?> get props => [message];

  const TemplateEditorError(this.message);
}
