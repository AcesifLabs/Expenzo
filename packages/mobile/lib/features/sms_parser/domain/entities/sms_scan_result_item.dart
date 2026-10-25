import 'package:equatable/equatable.dart';

import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

class SmsScanResultItem extends Equatable {
  final ParsedTransaction parsedTransaction;
  final String senderKey;
  final String senderLabel;

  /// The id an inbox scan gave this message before database v20, so a
  /// message imported back then isn't offered again.
  final String? legacySourceId;

  String get sourceId => parsedTransaction.sourceId;

  @override
  List<Object?> get props => [
    parsedTransaction,
    senderKey,
    senderLabel,
    legacySourceId,
  ];

  // Only inbox scans have an id from before v20.
  // ignore: unnecessary-nullable
  const SmsScanResultItem({
    required this.parsedTransaction,
    required this.senderKey,
    required this.senderLabel,
    this.legacySourceId,
  });
}
