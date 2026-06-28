import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../sms_parser/data/datasources/sms_local_datasource.dart';
import '../../../sms_parser/domain/entities/sms_message.dart';

abstract class SampleAnalyzerEvent extends Equatable {
  const SampleAnalyzerEvent();
  @override
  List<Object?> get props => [];
}

class LoadSamples extends SampleAnalyzerEvent {
  final String contactId;
  const LoadSamples({required this.contactId});
  @override
  List<Object?> get props => [contactId];
}

class LoadMoreSamples extends SampleAnalyzerEvent {
  final String contactId;
  const LoadMoreSamples({required this.contactId});
  @override
  List<Object?> get props => [contactId];
}

abstract class SampleAnalyzerState extends Equatable {
  const SampleAnalyzerState();
  @override
  List<Object?> get props => [];
}

class SampleAnalyzerInitial extends SampleAnalyzerState {}

class SampleAnalyzerLoading extends SampleAnalyzerState {}

class SampleAnalyzerLoaded extends SampleAnalyzerState {
  final List<SmsMessage> messages;
  final bool hasReachedMax;
  final bool isLoadingMore;

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

  @override
  List<Object?> get props => [messages, hasReachedMax, isLoadingMore];
}

class SampleAnalyzerError extends SampleAnalyzerState {
  final String message;
  const SampleAnalyzerError({required this.message});
  @override
  List<Object?> get props => [message];
}

class SampleAnalyzerBloc
    extends Bloc<SampleAnalyzerEvent, SampleAnalyzerState> {
  final SmsLocalDatasource smsDatasource;

  int _currentOffset = 0;
  final int _batchSize = 20;
  final List<SmsMessage> _messages = [];

  SampleAnalyzerBloc({required this.smsDatasource})
    : super(SampleAnalyzerInitial()) {
    on<LoadSamples>(_onLoadSamples);
    on<LoadMoreSamples>(_onLoadMoreSamples);
  }

  Future<void> _onLoadSamples(
    LoadSamples event,
    Emitter<SampleAnalyzerState> emit,
  ) async {
    emit(SampleAnalyzerLoading());
    _currentOffset = 0;
    _messages.clear();

    try {
      final messages = await smsDatasource.getSmsBatched(
        address: event.contactId,
        start: _currentOffset,
        count: _batchSize,
      );

      _messages.addAll(messages);
      _messages.sort((a, b) => b.date.compareTo(a.date));

      emit(
        SampleAnalyzerLoaded(
          messages: List.from(_messages),
          hasReachedMax: messages.length < _batchSize,
        ),
      );

      _currentOffset += messages.length;
    } catch (e) {
      emit(SampleAnalyzerError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreSamples(
    LoadMoreSamples event,
    Emitter<SampleAnalyzerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SampleAnalyzerLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final messages = await smsDatasource.getSmsBatched(
        address: event.contactId,
        start: _currentOffset,
        count: _batchSize,
      );

      if (messages.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true, isLoadingMore: false));
        return;
      }

      _messages.addAll(messages);
      _messages.sort((a, b) => b.date.compareTo(a.date));

      emit(
        SampleAnalyzerLoaded(
          messages: List.from(_messages),
          hasReachedMax: messages.length < _batchSize,
          isLoadingMore: false,
        ),
      );

      _currentOffset += messages.length;
    } catch (e) {
      emit(SampleAnalyzerError(message: e.toString()));
    }
  }
}
