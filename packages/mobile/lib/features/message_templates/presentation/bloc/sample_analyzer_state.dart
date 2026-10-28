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

  final Map<String, ExpenseTemplate> templatesBySample;

  final Map<String, ExpenseTemplate> matchedTemplatesByMessageBody;

  final ExpenseTemplate? pendingDeletion;

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
  final String message;

  @override
  List<Object?> get props => [message];

  const SampleAnalyzerError({required this.message});
}
