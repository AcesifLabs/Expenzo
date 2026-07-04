import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import '../../domain/entities/parsing_rule.dart';
import '../../domain/usecases/get_rules.dart';
import '../../domain/usecases/update_rule.dart';
import '../../domain/usecases/delete_rule.dart';
import '../../domain/repositories/parsing_rules_repository.dart';
import 'parsing_rules_event.dart';
import 'parsing_rules_state.dart';

class ParsingRulesBloc extends Bloc<ParsingRulesEvent, ParsingRulesState> {
  final GetRules getRules;
  final UpdateRule updateRule;
  final DeleteRule deleteRuleUseCase;
  final ParsingRulesRepository repository;
  StreamSubscription<List<ParsingRule>>? _rulesSubscription;

  ParsingRulesBloc({
    required this.getRules,
    required this.updateRule,
    required this.deleteRuleUseCase,
    required this.repository,
  }) : super(ParsingRulesInitial()) {
    on<LoadRules>(_onLoadRules, transformer: concurrent());
    on<CreateRuleEvent>(_onCreateRule, transformer: concurrent());
    on<RefreshRules>(_onRefreshRules, transformer: concurrent());
    on<ToggleRule>(_onToggleRule, transformer: concurrent());
    on<DeleteRuleRequested>(_onDeleteRule, transformer: concurrent());
    on<_RulesUpdated>(_onRulesUpdated, transformer: concurrent());
  }

  @override
  Future<void> close() {
    _rulesSubscription?.cancel();

    return super.close();
  }

  Future<void> _onLoadRules(
    LoadRules event,
    Emitter<ParsingRulesState> emit,
  ) async {
    emit(ParsingRulesLoading());

    await _rulesSubscription?.cancel();
    _rulesSubscription = repository.watchRules().listen((rules) {
      if (!isClosed) {
        add(_RulesUpdated(rules));
      }
    });

    final result = await getRules(GetRulesParams());
    result.fold(
      (failure) => emit(ParsingRulesError(message: failure.message)),
      (rules) => emit(ParsingRulesLoaded(rules: rules)),
    );
  }

  void _onRulesUpdated(_RulesUpdated event, Emitter<ParsingRulesState> emit) {
    emit(ParsingRulesLoaded(rules: event.rules));
  }

  Future<void> _onCreateRule(
    CreateRuleEvent event,
    Emitter<ParsingRulesState> emit,
  ) async {
    final result = await repository.createRule(event.rule);
    result.fold(
      (failure) => emit(ParsingRulesError(message: failure.message)),
      (_) => add(RefreshRules()),
    );
  }

  Future<void> _onRefreshRules(
    RefreshRules event,
    Emitter<ParsingRulesState> emit,
  ) async {
    final result = await getRules(GetRulesParams());
    result.fold(
      (failure) => emit(ParsingRulesError(message: failure.message)),
      (rules) => emit(ParsingRulesLoaded(rules: rules)),
    );
  }

  Future<void> _onToggleRule(
    ToggleRule event,
    Emitter<ParsingRulesState> emit,
  ) async {
    final currentState = state;
    if (currentState is ParsingRulesLoaded) {
      final rule = currentState.rules.firstWhere(
        (r) => r.id == event.ruleId,
        orElse: () => throw ArgumentError('Rule not found: ${event.ruleId}'),
      );

      final updatedRule = rule.copyWith(
        isEnabled: event.isEnabled,
        updatedAt: DateTime.now(),
      );

      final result = await updateRule(updatedRule);
      result.fold(
        (failure) => emit(ParsingRulesError(message: failure.message)),
        (_) => null,
      );
    }
  }

  Future<void> _onDeleteRule(
    DeleteRuleRequested event,
    Emitter<ParsingRulesState> emit,
  ) async {
    final result = await deleteRuleUseCase(event.ruleId);
    result.fold(
      (failure) => emit(ParsingRulesError(message: failure.message)),
      (_) => null,
    );
  }
}

class _RulesUpdated extends ParsingRulesEvent {
  final List<ParsingRule> rules;

  @override
  List<Object?> get props => [rules];

  const _RulesUpdated(this.rules);
}
