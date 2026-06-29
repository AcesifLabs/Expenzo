import 'package:equatable/equatable.dart';
import '../../domain/entities/parsing_rule.dart';

abstract class ParsingRulesState extends Equatable {
  @override
  List<Object?> get props => [];

  const ParsingRulesState();
}

class ParsingRulesInitial extends ParsingRulesState {}

class ParsingRulesLoading extends ParsingRulesState {}

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
