import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/shared/services/file_share_service.dart';

void main() {
  test('success and unavailable map to shared', () {
    expect(
      FileShareService.outcomeFor(ShareResultStatus.success),
      ShareOutcome.shared,
    );
    expect(
      FileShareService.outcomeFor(ShareResultStatus.unavailable),
      ShareOutcome.shared,
    );
  });

  test('dismissed maps to dismissed', () {
    expect(
      FileShareService.outcomeFor(ShareResultStatus.dismissed),
      ShareOutcome.dismissed,
    );
  });

  group('shareText', () {
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    final calls = <MethodCall>[];

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);

            // share_plus reads an empty result as dismissed.
            return '';
          });
    });

    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    test('passes the text to the share sheet and maps the result', () async {
      final outcome = await const FileShareService().shareText('Join RF4XK2');

      expect(calls.single.method, 'share');
      expect((calls.single.arguments as Map)['text'], 'Join RF4XK2');
      expect(outcome, ShareOutcome.dismissed);
    });
  });
}
