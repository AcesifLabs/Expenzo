import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/sms_parser/data/mappers/incoming_sms_event_mapper.dart';

void main() {
  group('mapIncomingSmsEventPayload', () {
    test('maps address and body from standard keys', () {
      final payload = {
        'address': '+1234567890',
        'body': 'Test message',
        'receivedAtMs': 1718451000000,
      };

      final result = mapIncomingSmsEventPayload(payload);

      expect(result.address, '+1234567890');
      expect(result.body, 'Test message');
    });

    test('falls back to sender/message keys', () {
      final payload = {
        'sender': 'Bank',
        'message': 'Your account was debited',
        'timestamp': 1718451000000,
      };

      final result = mapIncomingSmsEventPayload(payload);

      expect(result.address, 'Bank');
      expect(result.body, 'Your account was debited');
    });

    test('parses int timestamp as milliseconds', () {
      final payload = {
        'address': 'test',
        'body': 'test',
        'receivedAtMs': 1718451000000,
      };

      final result = mapIncomingSmsEventPayload(payload);

      expect(result.receivedAt.year, 2024);
    });

    test('parses string timestamp', () {
      final payload = {
        'address': 'test',
        'body': 'test',
        'date': '2024-06-15T10:30:00.000Z',
      };

      final result = mapIncomingSmsEventPayload(payload);

      expect(result.receivedAt.year, 2024);
      expect(result.receivedAt.month, 6);
    });

    test('parses numeric string timestamp', () {
      final payload = {
        'address': 'test',
        'body': 'test',
        'timestamp': '1718451000000',
      };

      final result = mapIncomingSmsEventPayload(payload);

      expect(result.receivedAt.year, 2024);
    });

    test('defaults to epoch for missing timestamp', () {
      final payload = {'address': 'test', 'body': 'test'};

      final result = mapIncomingSmsEventPayload(payload);

      expect(result.receivedAt.year, 1970);
    });

    test('defaults to empty strings for missing address/body', () {
      final payload = <String, dynamic>{};

      final result = mapIncomingSmsEventPayload(payload);

      expect(result.address, '');
      expect(result.body, '');
    });
  });
}
