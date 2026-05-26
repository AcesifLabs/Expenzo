import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/sms_parser/application/realtime_sms_processor.dart';
import 'package:expense_tracker/shared/presentation/widgets/sms_permission_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRealtimeSmsProcessor extends Mock implements RealtimeSmsProcessor {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');

  setUp(() {
    di.getIt.reset();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    di.getIt.reset();
  });

  testWidgets('granted permission shows child and starts realtime processor', (
    tester,
  ) async {
    final processor = _MockRealtimeSmsProcessor();
    when(() => processor.start()).thenAnswer((_) async {});
    di.getIt.registerSingleton<RealtimeSmsProcessor>(processor);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'checkPermissionStatus') return 1; // granted
          if (call.method == 'requestPermissions') return <int, int>{13: 1};
          return null;
        });

    await tester.pumpWidget(
      const MaterialApp(
        home: SmsPermissionGate(child: Text('SMS-CHILD')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SMS-CHILD'), findsOneWidget);
    verify(() => processor.start()).called(1);
  });

  testWidgets('denied permission shows access-required UI', (tester) async {
    final processor = _MockRealtimeSmsProcessor();
    when(() => processor.start()).thenAnswer((_) async {});
    di.getIt.registerSingleton<RealtimeSmsProcessor>(processor);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'checkPermissionStatus') return 0; // denied
          return null;
        });

    await tester.pumpWidget(
      const MaterialApp(
        home: SmsPermissionGate(child: Text('SMS-CHILD')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SMS Access Required'), findsOneWidget);
    expect(find.text('SMS-CHILD'), findsNothing);
    verifyNever(() => processor.start());
  });
}
