import 'package:equatable/equatable.dart';

import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

class SmsScanResultItem extends Equatable {
  final ParsedTransaction parsedTransaction;
  final String senderKey;
  final String senderLabel;

  final String legacySourceId;

  String get sourceId => parsedTransaction.sourceId;

  @override
  List<Object?> get props => [
    parsedTransaction,
    senderKey,
    senderLabel,
    legacySourceId,
  ];

  const SmsScanResultItem({
    required this.parsedTransaction,
    required this.senderKey,
    required this.senderLabel,
    required this.legacySourceId,
  });
}
