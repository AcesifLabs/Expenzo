import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';

abstract class TemplateEditorEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const TemplateEditorEvent();
}

class LoadTemplate extends TemplateEditorEvent {
  final String templateId;

  @override
  List<Object?> get props => [templateId];

  const LoadTemplate(this.templateId);
}

class SaveTemplateEvent extends TemplateEditorEvent {
  final ExpenseTemplate template;
  final MessageSource source;

  @override
  List<Object?> get props => [template, source];

  const SaveTemplateEvent(this.template, this.source);
}

class DeleteTemplateEvent extends TemplateEditorEvent {
  final String templateId;

  @override
  List<Object?> get props => [templateId];

  const DeleteTemplateEvent(this.templateId);
}
