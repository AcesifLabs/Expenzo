import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/sms_permission_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_localized.dart';

const _channel = MethodChannel('flutter.baseflow.com/permissions/methods');

/// Permission.sms is 13; PermissionStatus.denied is 0, permanentlyDenied 4.
void _answerSmsRequestWith(int status) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        _channel,
        (call) async => switch (call.method) {
          'checkPermissionStatus' => 0,
          'requestPermissions' => {13: status},
          _ => null,
        },
      );
}

void main() {
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null),
  );

  Future<void> pumpGateAndAllow(WidgetTester tester) async {
    await pumpLocalized(
      tester,
      const Scaffold(body: SmsPermissionGate(child: Text('senders'))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.common.smsGate.allow));
    await tester.pumpAndSettle();
  }

  testWidgets('refused for good, the gate points to app settings', (
    tester,
  ) async {
    _answerSmsRequestWith(4);

    await pumpGateAndAllow(tester);

    expect(find.text(t.common.smsGate.deniedTitle), findsOneWidget);
    expect(find.text('senders'), findsNothing);
  });

  testWidgets('refused once, the gate stays and can ask again', (tester) async {
    _answerSmsRequestWith(0);

    await pumpGateAndAllow(tester);

    expect(find.text(t.common.smsGate.deniedTitle), findsNothing);
    expect(find.text(t.common.smsGate.allow), findsOneWidget);
  });
}
