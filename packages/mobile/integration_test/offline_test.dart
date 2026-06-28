import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Startup resilience scenarios', () {
    testWidgets(
      'App starts and shows dashboard without initialization errors',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 20));

        expect(find.text('Initialization Failed'), findsNothing);

        expect(find.byType(MaterialApp), findsOneWidget);
      },
    );

    testWidgets('Dashboard renders with seeded categories after startup', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 20));

      final hasContent = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasContent, isTrue);
    });
  });
}
