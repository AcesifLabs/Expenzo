import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_template.dart';

abstract class TemplateEditorState extends Equatable {
  const TemplateEditorState();
  @override
  List<Object?> get props => [];
}

class TemplateEditorInitial extends TemplateEditorState {}

class TemplateEditorLoading extends TemplateEditorState {}

class TemplateEditorLoaded extends TemplateEditorState {
  final ExpenseTemplate? template;
  const TemplateEditorLoaded({this.template});
  @override
  List<Object?> get props => [template];
}

class TemplateEditorSaving extends TemplateEditorState {}

class TemplateEditorSaved extends TemplateEditorState {}

class TemplateEditorDeleted extends TemplateEditorState {}

class TemplateEditorError extends TemplateEditorState {
  final String message;
  const TemplateEditorError(this.message);
  @override
  List<Object?> get props => [message];
}
