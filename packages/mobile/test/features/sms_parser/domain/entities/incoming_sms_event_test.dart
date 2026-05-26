import 'package:expense_tracker/features/sms_parser/domain/entities/incoming_sms_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IncomingSmsEvent.sourceId', () {
    test('is equal for two instances with same payload', () {
      final first = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );
      final second = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );

      expect(first.sourceId, equals(second.sourceId));
    });

    test('is equal for timezone-equivalent instants', () {
      final utc = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );
      final plusFiveThirty = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T15:30:00+05:30'),
      );

      expect(utc.sourceId, equals(plusFiveThirty.sourceId));
    });

    test('changes when body changes', () {
      final base = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );
      final changed = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 220 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );

      expect(changed.sourceId, isNot(equals(base.sourceId)));
    });

    test('changes when timestamp changes', () {
      final first = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );
      final second = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:01Z'),
      );

      expect(first.sourceId, isNot(equals(second.sourceId)));
    });

    test('keeps sourceId stable for sender case/whitespace differences', () {
      final first = IncomingSmsEvent(
        address: '  vk-bank ',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );
      final second = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'INR 120 debited',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );

      expect(first.sourceId, equals(second.sourceId));
    });

    test('uses body hash for empty and unicode bodies', () {
      final emptyBody = IncomingSmsEvent(
        address: 'VK-BANK',
        body: '',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );
      final unicodeBody = IncomingSmsEvent(
        address: 'VK-BANK',
        body: 'Paid ₹923 ✅',
        receivedAt: DateTime.parse('2026-05-26T10:00:00Z'),
      );

      expect(emptyBody.sourceId, isNot(equals(unicodeBody.sourceId)));
    });
  });
}
