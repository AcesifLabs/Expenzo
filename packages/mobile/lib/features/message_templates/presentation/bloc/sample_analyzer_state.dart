import 'package:equatable/equatable.dart';
import '../../../sms_parser/domain/entities/sms_message.dart';

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

  @override
  List<Object?> get props => [messages, hasReachedMax, isLoadingMore];

  const SampleAnalyzerLoaded({
    required this.messages,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  SampleAnalyzerLoaded copyWith({
    List<SmsMessage>? messages,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return SampleAnalyzerLoaded(
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SampleAnalyzerError extends SampleAnalyzerState {
  final String message;

  @override
  List<Object?> get props => [message];

  const SampleAnalyzerError({required this.message});
}
