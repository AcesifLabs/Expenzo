import 'package:expense_tracker/shared/presentation/widgets/inline_error_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_localized.dart';

class _Throws extends StatelessWidget {
  const _Throws();

  @override
  Widget build(BuildContext context) => throw StateError('tile broke');
}

void main() {
  late ErrorWidgetBuilder previousBuilder;
  final platformCalls = <String>[];

  setUp(() {
    previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (details) => InlineErrorPlaceholder(details: details);
    platformCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          platformCalls.add(call.method);

          return null;
        });
  });

  tearDown(() {
    ErrorWidget.builder = previousBuilder;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('one broken widget leaves the rest of the screen up', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        home: const Scaffold(
          body: Column(children: [Text('Groceries'), _Throws()]),
        ),
      ),
    );
    expect(tester.takeException(), isStateError);

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.byType(InlineErrorPlaceholder), findsOneWidget);
    expect(find.textContaining('Something went wrong'), findsOneWidget);

    // The old full-screen error closed the app after 3 seconds.
    await tester.pump(const Duration(seconds: 5));
    expect(platformCalls, isNot(contains('SystemNavigator.pop')));
  });

  testWidgets('renders above MaterialApp without a text direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      translated(
        InlineErrorPlaceholder(
          details: FlutterErrorDetails(exception: StateError('root')),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Something went wrong'), findsOneWidget);
  });
}
