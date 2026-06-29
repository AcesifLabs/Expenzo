import 'package:equatable/equatable.dart';

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

class DeleteRuleRequested extends ParsingRulesEvent {
  final String ruleId;

  @override
  List<Object?> get props => [ruleId];

  const DeleteRuleRequested({required this.ruleId});
}
