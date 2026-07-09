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
    // Await the watcher tear-down so any in-flight tick that lands
    // while super.close() is draining still hits the
    // `if (isClosed) return;` guard inside the listener rather than
    // throwing on a closed bloc.
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

    // Single Drift subscription feeds both the initial snapshot AND
    // live updates. While we are still in `SampleAnalyzerLoading`,
    // ticks accumulate in `pendingInitialTick`; the first tick also
    // resolves `initialTickCompleter` so the bloc can move forward
    // only after Drift has at least emitted once. A Drift update
    // that races past the `await smsDatasource.getSmsBatched(...)`
    // suspend lands here and is folded into the first
    // `SampleAnalyzerLoaded` so it is never silently dropped.
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
      // Safety valve so a Drift tick that lands after this exception
      // does not keep the completer forever awaiting. (The listener
      // is still subscribed in `SampleAnalyzerError`; without this
      // the closure would never be released.)
      if (!initialTickCompleter.isCompleted) {
        initialTickCompleter.complete();
      }
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

      // `copyWith` preserves `templatesBySample`, `pendingDeletion`,
      // and `lastError` automatically — no need to re-pass them.
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
      emit(SampleAnalyzerError(message: e.toString()));
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
      // Preserve Loaded state on save-failure so the user stays on the
      // page; surface the failure via `lastError` (the Page shows it
      // as a SnackBar). Only fall back to a global
      // `SampleAnalyzerError` if there is no Loaded state to attach
      // the message to.
      addError(e, s);
      final latest = state;
      if (latest is SampleAnalyzerLoaded) {
        emit(
          latest.copyWith(
            clearPendingDeletion: true,
            lastError: 'Could not delete template: $e',
          ),
        );
      } else {
        emit(SampleAnalyzerError(message: 'Could not delete template: $e'));
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
      // Drop undo silently — another template is already parked on this
      // sample. Don't double-insert.
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
                lastError: 'Could not restore template: ${failure.message}',
              ),
            );
          } else {
            emit(
              SampleAnalyzerError(
                message: 'Could not restore template: ${failure.message}',
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
            lastError: 'Could not restore template: $e',
          ),
        );
      } else {
        emit(SampleAnalyzerError(message: 'Could not restore template: $e'));
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

/// Internal event that ferries Drift watcher ticks back into the bloc
/// through the same event queue as user-initiated events.
///
/// Why an event instead of calling `emit(...)` directly from the
/// listener:
///  - Drift's `select(...).watch()` emits on its own microtask. Calling
///    `emit` from inside that callback would race with user handlers
///    (e.g. `TemplateDeleted`) that are awaiting the same state.
///    Routing through `bloc.add(...)` serializes watcher-driven
///    `templatesBySample` updates alongside `LoadSamples`,
///    `TemplateDeleted`, etc., so state transitions stay linear.
///  - Tests can drive the watcher deterministically by calling
///    `watcherController.add([...])` to simulate a Drift update
///    without faking timers or `runAsync`.
class _TemplatesUpdated extends SampleAnalyzerEvent {
  final List<ExpenseTemplate> templates;

  @override
  List<Object?> get props => [templates];

  const _TemplatesUpdated(this.templates);
}
