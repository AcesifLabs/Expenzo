import 'package:equatable/equatable.dart';
import '../../domain/entities/parsing_rule.dart';

sealed class ParsingRulesState extends Equatable {
  @override
  List<Object?> get props => [];

  const ParsingRulesState();
}

class ParsingRulesInitial extends ParsingRulesState {
  const ParsingRulesInitial();
}

class ParsingRulesLoading extends ParsingRulesState {
  const ParsingRulesLoading();
}

class ParsingRulesLoaded extends ParsingRulesState {
  final List<ParsingRule> rules;

  @override
  List<Object?> get props => [rules];

  const ParsingRulesLoaded({required this.rules});
}

class ParsingRulesError extends ParsingRulesState {
  final String message;

  @override
  List<Object?> get props => [message];

  const ParsingRulesError({required this.message});
}
