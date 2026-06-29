import 'package:equatable/equatable.dart';
import '../../domain/entities/parsing_rule.dart';

abstract class ParsingRulesEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const ParsingRulesEvent();
}

class LoadRules extends ParsingRulesEvent {}

class RefreshRules extends ParsingRulesEvent {}

class ToggleRule extends ParsingRulesEvent {
  final String ruleId;
  final bool isEnabled;

  @override
  List<Object?> get props => [ruleId, isEnabled];

  const ToggleRule({required this.ruleId, required this.isEnabled});
}

class CreateRuleEvent extends ParsingRulesEvent {
  final ParsingRule rule;

  @override
  List<Object?> get props => [rule];

  const CreateRuleEvent(this.rule);
}

class DeleteRuleRequested extends ParsingRulesEvent {
  final String ruleId;

  @override
  List<Object?> get props => [ruleId];

  const DeleteRuleRequested({required this.ruleId});
}
