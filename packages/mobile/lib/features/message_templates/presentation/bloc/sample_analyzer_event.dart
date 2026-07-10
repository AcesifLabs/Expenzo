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

/// Fired by the page when the user taps Delete inside the
/// "Template already exists" sheet. The bloc captures the template as
/// `pendingDeletion`, hard-deletes the row, and emits a new state so the
/// Page can surface a SnackBar with an Undo action.
class TemplateDeleted extends SampleAnalyzerEvent {
  final ExpenseTemplate template;

  @override
  List<Object?> get props => [template];

  const TemplateDeleted(this.template);
}

/// Fired when the user taps Undo inside the SnackBar within the
/// 5-second window. The bloc re-inserts via `saveTemplate`
/// (`InsertMode.insertOrReplace`). If a template with the same
/// `sampleMessage` already exists for the source, the undo is dropped
/// silently — no duplicate insert.
class TemplateDeletionUndone extends SampleAnalyzerEvent {
  final ExpenseTemplate template;

  @override
  List<Object?> get props => [template];

  const TemplateDeletionUndone(this.template);
}

/// Fired when the SnackBar's 5-second window closes without an Undo.
/// Clears `pendingDeletion` so the page can stop showing the SnackBar
/// race window. The underlying row stays deleted.
class TemplateDeletionExpired extends SampleAnalyzerEvent {
  const TemplateDeletionExpired();
}

/// Fired by the page when the user taps "Dismiss" on the
/// `lastError` SnackBar, clearing the transient error from
/// `SampleAnalyzerLoaded.lastError`.
class LastErrorDismissed extends SampleAnalyzerEvent {
  const LastErrorDismissed();
}
