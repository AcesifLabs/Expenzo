import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
    on<LoadRules>(_onLoadRules);
    on<RefreshRules>(_onRefreshRules);
    on<ToggleRule>(_onToggleRule);
    on<DeleteRuleRequested>(_onDeleteRule);
    on<_RulesUpdated>(_onRulesUpdated);
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

  Future<void> _onRulesUpdated(
    _RulesUpdated event,
    Emitter<ParsingRulesState> emit,
  ) async {
    emit(ParsingRulesLoaded(rules: event.rules));
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
        orElse: () => throw Exception('Rule not found'),
      );

      final updatedRule = rule.copyWith(
        isEnabled: event.isEnabled,
        updatedAt: DateTime.now(),
      );

      final result = await updateRule(updatedRule);
      result.fold(
        (failure) => emit(ParsingRulesError(message: failure.message)),
        (_) {},
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
      (_) {},
    );
  }

  @override
  Future<void> close() {
    _rulesSubscription?.cancel();
    return super.close();
  }
}

/// Internal event fired by the reactive stream subscription.
class _RulesUpdated extends ParsingRulesEvent {
  final List<ParsingRule> rules;
  const _RulesUpdated(this.rules);

  @override
  List<Object?> get props => [rules];
}
