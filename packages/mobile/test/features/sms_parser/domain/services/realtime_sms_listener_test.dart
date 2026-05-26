import 'package:expense_tracker/features/sms_parser/data/mappers/incoming_sms_event_mapper.dart';
import 'package:expense_tracker/features/sms_parser/data/services/method_channel_realtime_sms_listener.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('mapIncomingSmsEventPayload', () {
    test('converts payload map into IncomingSmsEvent', () {
      final event = mapIncomingSmsEventPayload({
        'address': 'VK-BANK',
        'body': 'INR 120 debited',
        'receivedAtMs': 1780000000000,
      });

      expect(event.address, equals('VK-BANK'));
      expect(event.body, equals('INR 120 debited'));
      expect(
        event.receivedAt,
        equals(DateTime.fromMillisecondsSinceEpoch(1780000000000, isUtc: true)),
      );
    });

    test('supports sender and timestamp fallback keys', () {
      final event = mapIncomingSmsEventPayload({
        'sender': 'AX-FOO',
        'message': 'credited 99',
        'timestamp': '2026-05-26T10:00:00Z',
      });

      expect(event.address, equals('AX-FOO'));
      expect(event.body, equals('credited 99'));
      expect(event.receivedAt, equals(DateTime.parse('2026-05-26T10:00:00Z')));
    });
  });

  group('MethodChannelRealtimeSmsListener.drainPendingMessages', () {
    const channel = MethodChannel(
      MethodChannelRealtimeSmsListener.methodChannelName,
    );

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('maps pending payload list into IncomingSmsEvent list', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'drainPendingSmsEvents') {
              return <Map<String, Object?>>[
                {
                  'address': 'VK-BANK',
                  'body': 'debited 120',
                  'receivedAtMs': 1780000001000,
                },
                {
                  'sender': 'AX-FOO',
                  'message': 'credited 99',
                  'timestamp': '1780000002000',
                },
              ];
            }

            return null;
          });

      final listener = MethodChannelRealtimeSmsListener(methodChannel: channel);

      final events = await listener.drainPendingMessages();

      expect(events, hasLength(2));
      expect(events.first.address, equals('VK-BANK'));
      expect(events.first.body, equals('debited 120'));
      expect(
        events.first.receivedAt,
        equals(DateTime.fromMillisecondsSinceEpoch(1780000001000, isUtc: true)),
      );
      expect(events.last.address, equals('AX-FOO'));
      expect(events.last.body, equals('credited 99'));
      expect(
        events.last.receivedAt,
        equals(DateTime.fromMillisecondsSinceEpoch(1780000002000, isUtc: true)),
      );
    });
  });
}
