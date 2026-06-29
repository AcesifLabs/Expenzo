import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_template.dart';

abstract class TemplateEditorState extends Equatable {
  @override
  List<Object?> get props => [];

  const TemplateEditorState();
}

class TemplateEditorInitial extends TemplateEditorState {}

class TemplateEditorLoading extends TemplateEditorState {}

class TemplateEditorLoaded extends TemplateEditorState {
  final ExpenseTemplate? template;

  @override
  List<Object?> get props => [template];

  const TemplateEditorLoaded({this.template});
}

class TemplateEditorSaving extends TemplateEditorState {}

class TemplateEditorSaved extends TemplateEditorState {}

class TemplateEditorDeleted extends TemplateEditorState {}

class TemplateEditorError extends TemplateEditorState {
  final String message;

  @override
  List<Object?> get props => [message];

  const TemplateEditorError(this.message);
}
