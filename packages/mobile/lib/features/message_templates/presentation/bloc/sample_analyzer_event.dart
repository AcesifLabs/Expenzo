import 'package:equatable/equatable.dart';

abstract class SampleAnalyzerEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SampleAnalyzerEvent();
}

class LoadSamples extends SampleAnalyzerEvent {
  final String contactId;

  @override
  List<Object?> get props => [contactId];

  const LoadSamples({required this.contactId});
}

class LoadMoreSamples extends SampleAnalyzerEvent {
  final String contactId;

  @override
  List<Object?> get props => [contactId];

  const LoadMoreSamples({required this.contactId});
}
