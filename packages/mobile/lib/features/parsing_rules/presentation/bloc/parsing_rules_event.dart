import 'package:equatable/equatable.dart';

abstract class ParsingRulesEvent extends Equatable {
  const ParsingRulesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRules extends ParsingRulesEvent {}

class RefreshRules extends ParsingRulesEvent {}

class ToggleRule extends ParsingRulesEvent {
  final String ruleId;
  final bool isEnabled;

  const ToggleRule({required this.ruleId, required this.isEnabled});

  @override
  List<Object?> get props => [ruleId, isEnabled];
}

class DeleteRuleRequested extends ParsingRulesEvent {
  final String ruleId;

  const DeleteRuleRequested({required this.ruleId});

  @override
  List<Object?> get props => [ruleId];
}
