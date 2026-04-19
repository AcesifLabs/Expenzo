import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';

abstract class TemplateEditorEvent extends Equatable {
  const TemplateEditorEvent();
  @override
  List<Object?> get props => [];
}

class LoadTemplate extends TemplateEditorEvent {
  final String templateId;
  const LoadTemplate(this.templateId);
  @override
  List<Object?> get props => [templateId];
}

class SaveTemplateEvent extends TemplateEditorEvent {
  final ExpenseTemplate template;
  final MessageSource source; // Pass the source to be saved first

  const SaveTemplateEvent(this.template, this.source);
  @override
  List<Object?> get props => [template, source];
}

class DeleteTemplateEvent extends TemplateEditorEvent {
  final String templateId;
  const DeleteTemplateEvent(this.templateId);
  @override
  List<Object?> get props => [templateId];
}
