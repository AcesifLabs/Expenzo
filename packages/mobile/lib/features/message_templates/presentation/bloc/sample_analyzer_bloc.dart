import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/features/parsing_rules/domain/services/amount_match_resolver.dart';
import '../../../sms_parser/data/datasources/sms_local_datasource.dart';
import '../../../sms_parser/domain/entities/sms_message.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/repositories/message_template_repository.dart';
import 'sample_analyzer_event.dart';
import 'sample_analyzer_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class SampleAnalyzerBloc
    extends Bloc<SampleAnalyzerEvent, SampleAnalyzerState> {
  final SmsLocalDatasource smsDatasource;
  final MessageTemplateRepository templateRepository;

  int _currentOffset = 0;
  final int _batchSize = 20;
  final List<SmsMessage> _messages = [];
  List<ExpenseTemplate> _currentTemplates = const [];

  StreamSubscription<List<ExpenseTemplate>>? _templatesSubscription;

  SampleAnalyzerBloc({
    required this.smsDatasource,
    required this.templateRepository,
  }) : super(SampleAnalyzerInitial()) {
    on<LoadSamples>(_onLoadSamples, transformer: concurrent());
    on<LoadMoreSamples>(_onLoadMoreSamples, transformer: concurrent());
    on<TemplateDeleted>(_onTemplateDeleted, transformer: concurrent());
    on<TemplateDeletionUndone>(
      _onTemplateDeletionUndone,
      transformer: concurrent(),
    );
    on<TemplateDeletionExpired>(
      _onTemplateDeletionExpired,
      transformer: concurrent(),
    );
    on<LastErrorDismissed>(_onLastErrorDismissed, transformer: concurrent());
    on<_TemplatesUpdated>(_onTemplatesUpdated, transformer: concurrent());
  }

  @override
  Future<void> close() async {
    await _templatesSubscription?.cancel();
    _templatesSubscription = null;

    return super.close();
  }

  void _onTemplatesUpdated(
    _TemplatesUpdated event,
    Emitter<SampleAnalyzerState> emit,
  ) {
    final currentState = state;
    if (currentState is! SampleAnalyzerLoaded) return;

    emit(
      currentState.copyWith(
        templatesBySample: _indexBySample(event.templates),
        matchedTemplatesByMessageBody: _indexMatchesByVisibleMessage(
          _messages,
          event.templates,
        ),
      ),
    );
  }

  Future<void> _onLoadSamples(
    LoadSamples event,
    Emitter<SampleAnalyzerState> emit,
  ) async {
    emit(SampleAnalyzerLoading());
    _currentOffset = 0;
    _messages.clear();

    await _templatesSubscription?.cancel();

    var pendingInitialTick = const <ExpenseTemplate>[];
    final initialTickCompleter = Completer<void>();

    _templatesSubscription = templateRepository
        .watchTemplatesForSource(event.sourceId)
        .listen((templates) {
          if (isClosed) return;

          final current = state;
          if (current is SampleAnalyzerLoaded) {
            add(_TemplatesUpdated(templates));
          } else {
            pendingInitialTick = templates;
            if (!initialTickCompleter.isCompleted) {
              initialTickCompleter.complete();
            }
          }
        });

    try {
      await initialTickCompleter.future;

      final messages = await smsDatasource.getSmsBatched(
        address: event.contactId,
        start: _currentOffset,
        count: _batchSize,
      );

      _messages.addAll(messages);
      _messages.sort((a, b) => b.date.compareTo(a.date));
      _currentTemplates = pendingInitialTick;

      emit(
        SampleAnalyzerLoaded(
          messages: List.from(_messages),
          hasReachedMax: messages.length < _batchSize,
          templatesBySample: _indexBySample(pendingInitialTick),
          matchedTemplatesByMessageBody: _indexMatchesByVisibleMessage(
            _messages,
            pendingInitialTick,
          ),
        ),
      );

      _currentOffset += messages.length;
    } catch (e, s) {
      if (!initialTickCompleter.isCompleted) {
        initialTickCompleter.complete();
      }
      addError(e, s);
      emit(SampleAnalyzerError(message: t.common.errors.generic));
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
        currentState.copyWith(
          messages: List.from(_messages),
          hasReachedMax: messages.length < _batchSize,
          isLoadingMore: false,
          matchedTemplatesByMessageBody: _indexMatchesByVisibleMessage(
            _messages,
            _currentTemplates,
          ),
        ),
      );

      _currentOffset += messages.length;
    } catch (e, s) {
      addError(e, s);
      emit(SampleAnalyzerError(message: t.common.errors.generic));
    }
  }

  Future<void> _onTemplateDeleted(
    TemplateDeleted event,
    Emitter<SampleAnalyzerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SampleAnalyzerLoaded) return;

    emit(currentState.copyWith(pendingDeletion: event.template));

    try {
      await templateRepository.deleteTemplate(event.template.id);
    } catch (e, s) {
      addError(e, s);
      final latest = state;
      if (latest is SampleAnalyzerLoaded) {
        emit(
          latest.copyWith(
            clearPendingDeletion: true,
            lastError: t.messageTemplates.errors.deleteFailed,
          ),
        );
      } else {
        emit(
          SampleAnalyzerError(message: t.messageTemplates.errors.deleteFailed),
        );
      }
    }
  }

  Future<void> _onTemplateDeletionUndone(
    TemplateDeletionUndone event,
    Emitter<SampleAnalyzerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SampleAnalyzerLoaded) return;
    if (currentState.pendingDeletion?.id != event.template.id) return;

    final hasConflict = currentState.templatesBySample.values.any(
      (t) => t.sampleMessage == event.template.sampleMessage,
    );

    if (hasConflict) {
      emit(currentState.copyWith(clearPendingDeletion: true));

      return;
    }

    try {
      final result = await templateRepository.saveTemplate(event.template);
      result.fold(
        (failure) {
          addError(failure, StackTrace.current);
          final latest = state;
          if (latest is SampleAnalyzerLoaded) {
            emit(
              latest.copyWith(
                clearPendingDeletion: true,
                lastError: t.messageTemplates.errors.restoreFailed,
              ),
            );
          } else {
            emit(
              SampleAnalyzerError(
                message: t.messageTemplates.errors.restoreFailed,
              ),
            );
          }
        },
        (_) {
          final latest = state;
          if (latest is SampleAnalyzerLoaded) {
            emit(latest.copyWith(clearPendingDeletion: true));
          }
        },
      );
    } catch (e, s) {
      addError(e, s);
      final latest = state;
      if (latest is SampleAnalyzerLoaded) {
        emit(
          latest.copyWith(
            clearPendingDeletion: true,
            lastError: t.messageTemplates.errors.restoreFailed,
          ),
        );
      } else {
        emit(
          SampleAnalyzerError(message: t.messageTemplates.errors.restoreFailed),
        );
      }
    }
  }

  void _onTemplateDeletionExpired(
    TemplateDeletionExpired event,
    Emitter<SampleAnalyzerState> emit,
  ) {
    final currentState = state;
    if (currentState is! SampleAnalyzerLoaded) return;
    if (currentState.pendingDeletion == null) return;

    emit(currentState.copyWith(clearPendingDeletion: true));
  }

  void _onLastErrorDismissed(
    LastErrorDismissed event,
    Emitter<SampleAnalyzerState> emit,
  ) {
    final currentState = state;
    if (currentState is! SampleAnalyzerLoaded) return;
    if (currentState.lastError == null) return;

    emit(currentState.copyWith(clearLastError: true));
  }

  Map<String, ExpenseTemplate> _indexBySample(List<ExpenseTemplate> templates) {
    final map = <String, ExpenseTemplate>{};
    for (final t in templates) {
      map[t.sampleMessage] = t;
    }

    return map;
  }

  Map<String, ExpenseTemplate> _indexMatchesByVisibleMessage(
    List<SmsMessage> messages,
    List<ExpenseTemplate> templates,
  ) {
    final map = <String, ExpenseTemplate>{};
    for (final msg in messages) {
      for (final template in templates) {
        if (_templateMatchesMessage(template, msg)) {
          map[msg.body] = template;
          break;
        }
      }
    }

    return map;
  }

  bool _templateMatchesMessage(ExpenseTemplate template, SmsMessage message) {
    if (!message.body.toLowerCase().contains(
      template.triggerWord.toLowerCase(),
    )) {
      return false;
    }

    final regex = RegExp(template.amountPattern);
    final allMatches = regex.allMatches(message.body).toList();

    return resolveAmountMatch(
          allMatches,
          template.selectedAmount,
          message.body,
        ) !=
        null;
  }
}

class _TemplatesUpdated extends SampleAnalyzerEvent {
  final List<ExpenseTemplate> templates;

  @override
  List<Object?> get props => [templates];

  const _TemplatesUpdated(this.templates);
}
