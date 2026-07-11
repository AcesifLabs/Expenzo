import 'package:expense_tracker/features/sms_parser/domain/entities/sms_scan_result_item.dart';

import 'parsed_transaction_factory.dart';

extension SmsScanResultItemFactoryCopy on SmsScanResultItem {
  SmsScanResultItem copyWith({
    String? senderKey,
    String? senderLabel,
    DateTime? parsedTransactionDate,
  }) {
    return SmsScanResultItem(
      parsedTransaction: parsedTransaction.copyWith(
        date: parsedTransactionDate,
      ),
      senderKey: senderKey ?? this.senderKey,
      senderLabel: senderLabel ?? this.senderLabel,
    );
  }
}

SmsScanResultItem makeSmsScanResultItem({
  String? senderKey,
  String? senderLabel,
  String? sourceId,
}) {
  final parsedTransaction = makeParsedTransaction(sourceId: sourceId);

  return SmsScanResultItem(
    parsedTransaction: parsedTransaction,
    senderKey: senderKey ?? '+8801700000000',
    senderLabel: senderLabel ?? 'Test Bank',
  );
}
