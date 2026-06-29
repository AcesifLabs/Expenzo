class EvaluateRulesParams {
  final String rawMessage;
  final String sourceType;
  final String sourceId;
  final String? address;
  final DateTime? messageDate;

  EvaluateRulesParams({
    required this.rawMessage,
    required this.sourceType,
    required this.sourceId,
    this.address,
    this.messageDate,
  });
}
