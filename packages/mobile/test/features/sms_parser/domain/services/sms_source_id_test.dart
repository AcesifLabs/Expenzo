import 'package:expense_tracker/features/sms_parser/domain/entities/incoming_sms_event.dart';
import 'package:expense_tracker/features/sms_parser/domain/services/sms_source_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime.utc(2026, 10, 1, 9, 30);

  test('two messages from one sender at the same moment get different ids', () {
    expect(
      smsSourceId(address: 'BANK', at: at, body: 'Debited Tk 500'),
      isNot(smsSourceId(address: 'BANK', at: at, body: 'Debited Tk 900')),
    );
  });

  test('live and scanned imports of one message share the id', () {
    const body = 'Debited Tk 500';
    final live = IncomingSmsEvent(address: 'BANK', body: body, receivedAt: at);

    expect(live.sourceId, smsSourceId(address: 'BANK', at: at, body: body));
  });

  test('the legacy scan id is what scans stored before v20', () {
    expect(
      legacyScanSourceId(address: 'BANK', at: at),
      'BANK_${at.toIso8601String()}'.hashCode.abs().toString(),
    );
  });
}
