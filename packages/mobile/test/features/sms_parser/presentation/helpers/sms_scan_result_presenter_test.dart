import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/sms_parser/presentation/helpers/sms_scan_result_presenter.dart';

import '../../../../support/factories/sms_scan_result_item_factory.dart';

void main() {
  test('sortResultsNewestFirst orders flat results by newest date first', () {
    final older = makeSmsScanResultItem(
      sourceId: 'a',
    ).copyWith(parsedTransactionDate: DateTime(2026, 7, 10));
    final newer = makeSmsScanResultItem(
      sourceId: 'b',
    ).copyWith(parsedTransactionDate: DateTime(2026, 7, 11));

    final sorted = sortResultsNewestFirst([older, newer]);

    expect(sorted.map((item) => item.sourceId).toList(), ['b', 'a']);
  });

  test('buildSenderSections groups by stable sender key', () {
    final first = makeSmsScanResultItem(
      sourceId: 'a',
      senderKey: 'BANK_A',
      senderLabel: 'Bank A',
    );
    final second = makeSmsScanResultItem(
      sourceId: 'b',
      senderKey: 'BANK_A',
      senderLabel: 'Bank A duplicate label',
    );
    final third = makeSmsScanResultItem(
      sourceId: 'c',
      senderKey: 'BANK_B',
      senderLabel: 'Bank B',
    );

    final sections = buildSenderSections([first, second, third]);

    expect(sections.length, 2);
    expect(sections.first.senderKey, 'BANK_A');
    expect(sections.first.items.map((item) => item.sourceId).toList(), [
      'a',
      'b',
    ]);
  });
}
