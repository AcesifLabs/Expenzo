import 'package:equatable/equatable.dart';
import '../../../sms_parser/domain/entities/sms_message.dart';
import '../../domain/entities/expense_template.dart';

sealed class SampleAnalyzerState extends Equatable {
  @override
  List<Object?> get props => [];

  const SampleAnalyzerState();
}

class SampleAnalyzerInitial extends SampleAnalyzerState {}

class SampleAnalyzerLoading extends SampleAnalyzerState {}

class SampleAnalyzerLoaded extends SampleAnalyzerState {
  final List<SmsMessage> messages;
  final bool hasReachedMax;
  final bool isLoadingMore;

  /// Indexed by `ExpenseTemplate.sampleMessage` so per-message lookup is O(1):
  /// `templatesBySample.containsKey(msg.body)` answers "is this message
  /// templated?" without scanning the list.
  final Map<String, ExpenseTemplate> templatesBySample;

  /// Indexed by visible SMS body so the page can surface sender-wide template
  /// matches while preserving exact sample-message semantics elsewhere.
  final Map<String, ExpenseTemplate> matchedTemplatesByMessageBody;

  /// Held between a `TemplateDeleted` event and either a successful
  /// `TemplateDeletionUndone` or a `TemplateDeletionExpired`.
  /// The Page listens for [pendingDeletion] becoming non-null to show a
  /// SnackBar with an Undo action.
  final ExpenseTemplate? pendingDeletion;

  /// Transient message surfaced when a save/restore/delete call fails
  /// while this Loaded state was alive. The Page shows it via a
  /// SnackBar with a Dismiss action (which dispatches
  /// `LastErrorDismissed` to clear this field); the Loaded state is
  /// preserved so the user is not kicked back into a global error
  /// screen.
  final String? lastError;

  @override
  List<Object?> get props => [
    messages,
    hasReachedMax,
    isLoadingMore,
    templatesBySample,
    matchedTemplatesByMessageBody,
    pendingDeletion,
    lastError,
  ];

  const SampleAnalyzerLoaded({
    required this.messages,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.templatesBySample = const <String, ExpenseTemplate>{},
    this.matchedTemplatesByMessageBody = const <String, ExpenseTemplate>{},
    this.pendingDeletion,
    this.lastError,
  });

  SampleAnalyzerLoaded copyWith({
    List<SmsMessage>? messages,
    bool? hasReachedMax,
    bool? isLoadingMore,
    Map<String, ExpenseTemplate>? templatesBySample,
    Map<String, ExpenseTemplate>? matchedTemplatesByMessageBody,
    ExpenseTemplate? pendingDeletion,
    bool clearPendingDeletion = false,
    String? lastError,
    bool clearLastError = false,
  }) {
    return SampleAnalyzerLoaded(
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      templatesBySample: templatesBySample ?? this.templatesBySample,
      matchedTemplatesByMessageBody:
          matchedTemplatesByMessageBody ?? this.matchedTemplatesByMessageBody,
      pendingDeletion: clearPendingDeletion
          ? null
          : (pendingDeletion ?? this.pendingDeletion),
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }
}

class SampleAnalyzerError extends SampleAnalyzerState {
  // Kept for first-load failures where there is no Loaded state to
  // fall back to. Save/restore/delete failures that occur while a
  // Loaded state is alive stay inside `SampleAnalyzerLoaded.lastError`
  // so the user remains on the page and can retry.
  final String message;

  @override
  List<Object?> get props => [message];

  const SampleAnalyzerError({required this.message});
}
