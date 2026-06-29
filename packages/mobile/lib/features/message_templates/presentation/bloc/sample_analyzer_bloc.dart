import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import '../../../sms_parser/data/datasources/sms_local_datasource.dart';
import '../../../sms_parser/domain/entities/sms_message.dart';
import 'sample_analyzer_event.dart';
import 'sample_analyzer_state.dart';

class SampleAnalyzerBloc
    extends Bloc<SampleAnalyzerEvent, SampleAnalyzerState> {
  final SmsLocalDatasource smsDatasource;

  int _currentOffset = 0;
  final int _batchSize = 20;
  final List<SmsMessage> _messages = [];

  SampleAnalyzerBloc({required this.smsDatasource})
    : super(SampleAnalyzerInitial()) {
    on<LoadSamples>(_onLoadSamples, transformer: concurrent());
    on<LoadMoreSamples>(_onLoadMoreSamples, transformer: concurrent());
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
    } catch (e, s) {
      addError(e, s);
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
    } catch (e, s) {
      addError(e, s);
      emit(SampleAnalyzerError(message: e.toString()));
    }
  }
}
