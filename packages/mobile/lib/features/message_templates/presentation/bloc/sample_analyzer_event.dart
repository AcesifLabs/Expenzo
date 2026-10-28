import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_template.dart';

abstract class SampleAnalyzerEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SampleAnalyzerEvent();
}

class LoadSamples extends SampleAnalyzerEvent {
  final String contactId;
  final String sourceId;

  @override
  List<Object?> get props => [contactId, sourceId];

  const LoadSamples({required this.contactId, required this.sourceId});
}

class LoadMoreSamples extends SampleAnalyzerEvent {
  final String contactId;
  final String sourceId;

  @override
  List<Object?> get props => [contactId, sourceId];

  const LoadMoreSamples({required this.contactId, required this.sourceId});
}

class TemplateDeleted extends SampleAnalyzerEvent {
  final ExpenseTemplate template;

  @override
  List<Object?> get props => [template];

  const TemplateDeleted(this.template);
}

class TemplateDeletionUndone extends SampleAnalyzerEvent {
  final ExpenseTemplate template;

  @override
  List<Object?> get props => [template];

  const TemplateDeletionUndone(this.template);
}

class TemplateDeletionExpired extends SampleAnalyzerEvent {
  const TemplateDeletionExpired();
}

class LastErrorDismissed extends SampleAnalyzerEvent {
  const LastErrorDismissed();
}
