import '../../domain/entities/sms_scan_result_item.dart';
import '../models/sender_result_section.dart';

List<SmsScanResultItem> sortResultsNewestFirst(
  List<SmsScanResultItem> results,
) {
  final sorted = [...results];
  sorted.sort((left, right) {
    final leftDate = left.parsedTransaction.date;
    final rightDate = right.parsedTransaction.date;

    if (leftDate == null && rightDate == null) return 0;
    if (leftDate == null) return 1;
    if (rightDate == null) return -1;

    return rightDate.compareTo(leftDate);
  });

  return sorted;
}

List<SenderResultSection> buildSenderSections(List<SmsScanResultItem> results) {
  final grouped = <String, List<SmsScanResultItem>>{};

  for (final result in sortResultsNewestFirst(results)) {
    grouped.putIfAbsent(result.senderKey, () => []).add(result);
  }

  final sections = grouped.entries.map((entry) {
    final first = entry.value.first;

    return SenderResultSection(
      senderKey: entry.key,
      senderLabel: first.senderLabel,
      items: entry.value,
    );
  }).toList();

  sections.sort((left, right) {
    final leftDate = left.items.first.parsedTransaction.date;
    final rightDate = right.items.first.parsedTransaction.date;

    if (leftDate == null && rightDate == null) {
      return left.senderLabel.compareTo(right.senderLabel);
    }
    if (leftDate == null) return 1;
    if (rightDate == null) return -1;

    return rightDate.compareTo(leftDate);
  });

  return sections;
}
