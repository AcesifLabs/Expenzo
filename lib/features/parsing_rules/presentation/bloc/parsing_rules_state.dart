import 'package:equatable/equatable.dart';
import '../../domain/entities/parsing_rule.dart';

abstract class ParsingRulesState extends Equatable {
  const ParsingRulesState();

  @override
  List<Object?> get props => [];
}

class ParsingRulesInitial extends ParsingRulesState {}

class ParsingRulesLoading extends ParsingRulesState {}

class ParsingRulesLoaded extends ParsingRulesState {
  final List<ParsingRule> rules;

  const ParsingRulesLoaded({required this.rules});

  @override
  List<Object?> get props => [rules];
}

class ParsingRulesError extends ParsingRulesState {
  final String message;

  const ParsingRulesError({required this.message});

  @override
  List<Object?> get props => [message];
}
