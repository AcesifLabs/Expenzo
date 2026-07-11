import '../../domain/entities/sms_scan_result_item.dart';

class SenderResultSection {
  final String senderKey;
  final String senderLabel;
  final List<SmsScanResultItem> items;

  const SenderResultSection({
    required this.senderKey,
    required this.senderLabel,
    required this.items,
  });
}
