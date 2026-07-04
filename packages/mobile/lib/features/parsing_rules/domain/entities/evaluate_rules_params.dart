import 'package:equatable/equatable.dart';

class EvaluateRulesParams extends Equatable {
  final String rawMessage;
  final String sourceType;
  final String sourceId;
  final String? address;
  final DateTime? messageDate;

  @override
  List<Object?> get props => [
    rawMessage,
    sourceType,
    sourceId,
    address,
    messageDate,
  ];

  const EvaluateRulesParams({
    required this.rawMessage,
    required this.sourceType,
    required this.sourceId,
    this.address,
    this.messageDate,
  });
}
